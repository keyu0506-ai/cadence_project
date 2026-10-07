const test = require('node:test');
const assert = require('node:assert/strict');
const {extractTasksForRequest, validateInput, validateOutput} = require('./task-extraction');

const context = {currentDate: '2026-10-07', timeZone: 'America/Los_Angeles', utcOffsetMinutes: -420};
const task = {title: 'Read chapter 3', subject: 'Biology', dueDate: '2026-10-12', notes: null};
const png = 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=';

test('Rejects unauthenticated calls before touching OpenAI', async () => {
  await assert.rejects(extractTasksForRequest({data: {...context, text: 'Read'}}, () => {
    assert.fail('Must not call OpenAI');
  }, 'test'), {code: 'unauthenticated'});
});
test('Validates source, local date and file constraints', () => {
  for (const data of [{...context}, {...context, text: 'a', imageBase64: png},
    {...context, text: 'a'.repeat(20001)}, {...context, text: 'a', currentDate: '2026-02-30'},
    {...context, imageBase64: 'invalid'}, {...context, imageBase64: Buffer.from('not an image').toString('base64')}]) {
    assert.throws(() => validateInput(data), {code: 'invalid-argument'});
  }
  assert.equal(validateInput({...context, imageBase64: png})[1].type, 'input_image');
});
test('Sends source image, structured schema and no storage flag; returns validated drafts', async () => {
  let request;
  const result = await extractTasksForRequest({auth: {uid: 'user'}, data: {...context, imageBase64: png}},
    () => ({responses: {create: async (input) => {request = input; return {status: 'completed', output_text: JSON.stringify({tasks: [task]})};}}}), 'model');
  assert.deepEqual(result, {tasks: [task]});
  assert.equal(request.store, false);
  assert.equal(request.text.format.strict, true);
  assert.match(request.input[0].content[1].image_url, /^data:image\/png;base64,/);
});
test('Allows no tasks and unknown deadlines; rejects invented calendar dates', () => {
  assert.deepEqual(validateOutput({tasks: []}), {tasks: []});
  assert.equal(validateOutput({tasks: [{...task, dueDate: null}]}).tasks[0].dueDate, null);
  assert.throws(() => validateOutput({tasks: [{...task, dueDate: '2026-02-30'}]}), {code: 'data-loss'});
  assert.throws(() => validateOutput({tasks: [{...task, subject: 123}]}), {code: 'data-loss'});
});
test('Handles incomplete/refused outputs and sanitizes upstream failures', async () => {
  const request = {auth: {uid: 'user'}, data: {...context, text: 'Read chapter 3'}};
  await assert.rejects(extractTasksForRequest(request, () => ({responses: {create: async () => ({status: 'incomplete'})}}), 'test'), {code: 'failed-precondition'});
  await assert.rejects(extractTasksForRequest(request, () => ({responses: {create: async () => {throw {status: 429, message: 'sensitive upstream text'};}}}), 'test'), {code: 'resource-exhausted', message: 'Extraction is busy. Please try again later.'});
});

test('Identifies exhausted API credits without suggesting a different image', async () => {
  await assert.rejects(extractTasksForRequest({auth: {uid: 'user'}, data: {...context, text: 'Read'}},
    () => ({responses: {create: async () => {throw {status: 429, code: 'credit_balance_exhausted'};}}}), 'test'),
    (error) => error.code === 'resource-exhausted' && error.details.reason === 'quota');
});
