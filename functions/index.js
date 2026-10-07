const {onCall} = require('firebase-functions/v2/https');
const {defineSecret, defineString} = require('firebase-functions/params');
const {extractTasksForRequest} = require('./task-extraction');

const openaiKey = defineSecret('OPENAI_API_KEY');
const extractionModel = defineString('TASK_EXTRACTION_MODEL', {default: 'gpt-4.1-mini'});

exports.extractTasks = onCall({
  region: 'us-central1',
  secrets: [openaiKey],
  timeoutSeconds: 90,
  memory: '512MiB',
  maxInstances: 3,
  concurrency: 10,
}, async (request) => {
  // The secret is accessed only inside the deployed function, never in Flutter.
  return extractTasksForRequest(request, () => {
    // Load the SDK only for requests, not during Firebase's deployment discovery.
    const OpenAI = require('openai');
    return new OpenAI({
      apiKey: openaiKey.value(), timeout: 65000, maxRetries: 0,
    });
  }, extractionModel.value());
});
