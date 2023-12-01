const AWS = require('aws-sdk');

const sns = new AWS.SNS();

exports.handler = async (event) => {
  console.log('Lambda function invoked!');

  const snsParams = {
    Message: `Lambda function invoked!\nAPI URL: ${process.env.API_URL}`,
    Subject: 'Lambda Notification',
    TopicArn: process.env.SNS_TOPIC_ARN
  };

  await sns.publish(snsParams).promise();

  return {
    statusCode: 200,
    body: JSON.stringify('Lambda function invoked'),
  };
};
