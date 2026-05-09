/**
 * Integration Tests for Scenario A
 * 
 * Test suite per validare l'orchestrazione multi-sistema
 * e le trasformazioni VETRO.
 * 
 * Prerequisiti:
 * - Backend services running (ERP, MES, QMS)
 * - PostgreSQL database initialized
 * - ACE Integration Server running
 * - API Connect Gateway configured
 */

const axios = require('axios');
const { expect } = require('chai');
const { describe, it, before, after } = require('mocha');

// Configuration
const config = {
  // Backend Services
  erpService: process.env.ERP_SERVICE_URL || 'http://localhost:3001',
  mesService: process.env.MES_SERVICE_URL || 'http://localhost:3002',
  qmsService: process.env.QMS_SERVICE_URL || 'http://localhost:3003',
  
  // ACE Integration Server
  aceServer: process.env.ACE_SERVER_URL || 'http://localhost:7800',
  
  // API Connect Gateway
  apiGateway: process.env.API_GATEWAY_URL || 'http://localhost:9443',
  
  // OAuth2
  oauth2TokenUrl: process.env.OAUTH2_TOKEN_URL || 'http://localhost:9443/oauth2/token',
  clientId: process.env.CLIENT_ID || 'test-client',
  clientSecret: process.env.CLIENT_SECRET || 'test-secret',
  
  // Test Data
  testOrderId: 'ORD-2026-001',
  invalidOrderId: 'ORD-9999-999'
};

// Global variables
let accessToken = null;

/**
 * Helper Functions
 */

// Get OAuth2 Access Token
async function getAccessToken() {
  try {
    const response = await axios.post(config.oauth2TokenUrl, 
      new URLSearchParams({
        grant_type: 'client_credentials',
        client_id: config.clientId,
        client_secret: config.clientSecret,
        scope: 'orders:read'
      }),
      {
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded'
        }
      }
    );
    return response.data.access_token;
  } catch (error) {
    console.warn('OAuth2 not configured, proceeding without token');
    return null;
  }
}

// Create HTTP headers
function createHeaders(includeAuth = true) {
  const headers = {
    'Content-Type': 'application/json',
    'X-Request-ID': `test-${Date.now()}`
  };
  
  if (includeAuth && accessToken) {
    headers['Authorization'] = `Bearer ${accessToken}`;
  }
  
  return headers;
}

// Measure response time
async function measureResponseTime(fn) {
  const start = Date.now();
  const result = await fn();
  const duration = Date.now() - start;
  return { result, duration };
}

/**
 * Test Suites
 */

describe('Backend Services Health Checks', function() {
  this.timeout(10000);
  
  it('ERP Service should be healthy', async () => {
    const response = await axios.get(`${config.erpService}/health`);
    expect(response.status).to.equal(200);
    expect(response.data.status).to.equal('healthy');
  });
  
  it('MES Service should be healthy', async () => {
    const response = await axios.get(`${config.mesService}/health`);
    expect(response.status).to.equal(200);
    expect(response.data.status).to.equal('healthy');
  });
  
  it('QMS Service should be healthy', async () => {
    const response = await axios.get(`${config.qmsService}/health`);
    expect(response.status).to.equal(200);
    expect(response.data.status).to.equal('healthy');
  });
});

describe('Backend Services Connectivity', function() {
  this.timeout(10000);
  
  it('ERP Service should return order data', async () => {
    const response = await axios.get(
      `${config.erpService}/api/v1/orders/${config.testOrderId}`,
      { headers: createHeaders(false) }
    );
    
    expect(response.status).to.equal(200);
    expect(response.data.data).to.have.property('order_id');
    expect(response.data.data.order_id).to.equal(config.testOrderId);
  });
  
  it('MES Service should return production steps', async () => {
    const response = await axios.get(
      `${config.mesService}/api/v1/production-steps?orderId=${config.testOrderId}`,
      { headers: createHeaders(false) }
    );
    
    expect(response.status).to.equal(200);
    expect(response.data.data).to.have.property('steps');
    expect(response.data.data.steps).to.be.an('array');
  });
  
  it('QMS Service should return quality checks', async () => {
    const response = await axios.get(
      `${config.qmsService}/api/v1/quality-checks?stepIds=1,2,3`,
      { headers: createHeaders(false) }
    );
    
    expect(response.status).to.equal(200);
    expect(response.data.data).to.have.property('checks');
    expect(response.data.data.checks).to.be.an('array');
  });
});

describe('ACE Integration Server - Orchestration', function() {
  this.timeout(30000);
  
  before(async () => {
    // Get OAuth2 token if configured
    accessToken = await getAccessToken();
  });
  
  it('Should orchestrate all three backend services', async () => {
    const { result, duration } = await measureResponseTime(async () => {
      return await axios.get(
        `${config.aceServer}/api/v1/orders/${config.testOrderId}`,
        { headers: createHeaders() }
      );
    });
    
    expect(result.status).to.equal(200);
    expect(result.data).to.have.property('order');
    expect(result.data.order).to.have.property('orderId');
    expect(result.data.order).to.have.property('production');
    expect(result.data.order).to.have.property('quality');
    
    console.log(`  ✓ Response time: ${duration}ms`);
    expect(duration).to.be.below(5000); // Should respond within 5 seconds
  });
  
  it('Should return consolidated data in canonical model', async () => {
    const response = await axios.get(
      `${config.aceServer}/api/v1/orders/${config.testOrderId}`,
      { headers: createHeaders() }
    );
    
    const order = response.data.order;
    
    // Verify ERP data transformation
    expect(order).to.have.property('orderId');
    expect(order).to.have.property('orderNumber');
    expect(order).to.have.property('customer');
    expect(order.customer).to.have.property('name');
    expect(order).to.have.property('financial');
    expect(order.financial).to.have.property('totalAmount');
    
    // Verify MES data transformation
    expect(order).to.have.property('production');
    expect(order.production).to.have.property('summary');
    expect(order.production.summary).to.have.property('totalSteps');
    expect(order.production.summary).to.have.property('completionPercentage');
    expect(order.production).to.have.property('steps');
    
    // Verify QMS data transformation
    expect(order).to.have.property('quality');
    expect(order.quality).to.have.property('summary');
    expect(order.quality.summary).to.have.property('totalChecks');
    expect(order.quality.summary).to.have.property('passRate');
    expect(order.quality).to.have.property('checks');
  });
  
  it('Should include metadata and HATEOAS links', async () => {
    const response = await axios.get(
      `${config.aceServer}/api/v1/orders/${config.testOrderId}`,
      { headers: createHeaders() }
    );
    
    // Verify metadata
    expect(response.data).to.have.property('metadata');
    expect(response.data.metadata).to.have.property('orchestrationTimestamp');
    expect(response.data.metadata).to.have.property('version');
    
    // Verify HATEOAS links
    expect(response.data).to.have.property('_links');
    expect(response.data._links).to.have.property('self');
    expect(response.data._links.self).to.have.property('href');
  });
  
  it('Should handle non-existent order gracefully', async () => {
    try {
      await axios.get(
        `${config.aceServer}/api/v1/orders/${config.invalidOrderId}`,
        { headers: createHeaders() }
      );
      expect.fail('Should have thrown 404 error');
    } catch (error) {
      expect(error.response.status).to.equal(404);
      expect(error.response.data).to.have.property('error');
      expect(error.response.data.error).to.have.property('code');
    }
  });
  
  it('Should handle partial failures with warnings', async () => {
    // This test requires simulating a backend failure
    // For now, we just verify the structure supports partial responses
    const response = await axios.get(
      `${config.aceServer}/api/v1/orders/${config.testOrderId}`,
      { headers: createHeaders() }
    );
    
    // If warnings exist, verify structure
    if (response.data.warnings) {
      expect(response.data.warnings).to.be.an('array');
      response.data.warnings.forEach(warning => {
        expect(warning).to.have.property('service');
        expect(warning).to.have.property('message');
        expect(warning).to.have.property('severity');
      });
    }
  });
});

describe('Data Transformation - VETRO Pattern', function() {
  this.timeout(10000);
  
  it('Should validate input (Validate)', async () => {
    try {
      await axios.get(
        `${config.aceServer}/api/v1/orders/INVALID-FORMAT`,
        { headers: createHeaders() }
      );
      expect.fail('Should have thrown validation error');
    } catch (error) {
      expect(error.response.status).to.be.oneOf([400, 404]);
    }
  });
  
  it('Should enrich with backend data (Enrich)', async () => {
    const response = await axios.get(
      `${config.aceServer}/api/v1/orders/${config.testOrderId}`,
      { headers: createHeaders() }
    );
    
    // Verify data from all three backends is present
    expect(response.data.order).to.have.property('orderId'); // ERP
    expect(response.data.order).to.have.property('production'); // MES
    expect(response.data.order).to.have.property('quality'); // QMS
  });
  
  it('Should transform to canonical model (Transform)', async () => {
    const response = await axios.get(
      `${config.aceServer}/api/v1/orders/${config.testOrderId}`,
      { headers: createHeaders() }
    );
    
    const order = response.data.order;
    
    // Verify field name transformations
    // ERP: order_id -> orderId
    expect(order).to.have.property('orderId');
    expect(order).to.not.have.property('order_id');
    
    // MES: quantityPlanned -> quantity.planned
    if (order.production.steps.length > 0) {
      const step = order.production.steps[0];
      expect(step).to.have.property('quantity');
      expect(step.quantity).to.have.property('planned');
    }
    
    // QMS: checkType -> checkType (no change but verify structure)
    if (order.quality.checks.length > 0) {
      const check = order.quality.checks[0];
      expect(check).to.have.property('checkType');
      expect(check).to.have.property('result');
    }
  });
  
  it('Should calculate derived fields (Operate)', async () => {
    const response = await axios.get(
      `${config.aceServer}/api/v1/orders/${config.testOrderId}`,
      { headers: createHeaders() }
    );
    
    const order = response.data.order;
    
    // Verify calculated completion percentage
    if (order.production.summary.totalSteps > 0) {
      const expectedPercentage = 
        (order.production.summary.completedSteps / order.production.summary.totalSteps) * 100;
      expect(order.production.summary.completionPercentage).to.be.closeTo(expectedPercentage, 0.1);
    }
    
    // Verify calculated pass rate
    if (order.quality.summary.totalChecks > 0) {
      const expectedPassRate = 
        (order.quality.summary.passedChecks / order.quality.summary.totalChecks) * 100;
      expect(order.quality.summary.passRate).to.be.closeTo(expectedPassRate, 0.1);
    }
  });
});

describe('Error Handling and Resilience', function() {
  this.timeout(10000);
  
  it('Should handle invalid orderId format', async () => {
    try {
      await axios.get(
        `${config.aceServer}/api/v1/orders/invalid`,
        { headers: createHeaders() }
      );
      expect.fail('Should have thrown error');
    } catch (error) {
      expect(error.response.status).to.be.oneOf([400, 404]);
      expect(error.response.data).to.have.property('error');
    }
  });
  
  it('Should include request ID in response headers', async () => {
    const requestId = `test-${Date.now()}`;
    const response = await axios.get(
      `${config.aceServer}/api/v1/orders/${config.testOrderId}`,
      { 
        headers: {
          ...createHeaders(),
          'X-Request-ID': requestId
        }
      }
    );
    
    // Verify request ID is echoed back
    expect(response.headers).to.have.property('x-request-id');
  });
  
  it('Should include response time in headers', async () => {
    const response = await axios.get(
      `${config.aceServer}/api/v1/orders/${config.testOrderId}`,
      { headers: createHeaders() }
    );
    
    expect(response.headers).to.have.property('x-response-time');
  });
});

describe('Performance Tests', function() {
  this.timeout(60000);
  
  it('Should handle concurrent requests', async () => {
    const concurrentRequests = 10;
    const requests = [];
    
    for (let i = 0; i < concurrentRequests; i++) {
      requests.push(
        axios.get(
          `${config.aceServer}/api/v1/orders/${config.testOrderId}`,
          { headers: createHeaders() }
        )
      );
    }
    
    const results = await Promise.all(requests);
    
    results.forEach(response => {
      expect(response.status).to.equal(200);
      expect(response.data).to.have.property('order');
    });
    
    console.log(`  ✓ Successfully handled ${concurrentRequests} concurrent requests`);
  });
  
  it('Should maintain acceptable response times under load', async () => {
    const iterations = 20;
    const responseTimes = [];
    
    for (let i = 0; i < iterations; i++) {
      const { duration } = await measureResponseTime(async () => {
        return await axios.get(
          `${config.aceServer}/api/v1/orders/${config.testOrderId}`,
          { headers: createHeaders() }
        );
      });
      responseTimes.push(duration);
    }
    
    const avgResponseTime = responseTimes.reduce((a, b) => a + b, 0) / responseTimes.length;
    const maxResponseTime = Math.max(...responseTimes);
    
    console.log(`  ✓ Average response time: ${avgResponseTime.toFixed(2)}ms`);
    console.log(`  ✓ Max response time: ${maxResponseTime}ms`);
    
    expect(avgResponseTime).to.be.below(2000); // Average < 2s
    expect(maxResponseTime).to.be.below(5000); // Max < 5s
  });
});

describe('API Gateway Integration', function() {
  this.timeout(10000);
  
  it('Should be accessible through API Gateway', async function() {
    if (!config.apiGateway.includes('localhost')) {
      const response = await axios.get(
        `${config.apiGateway}/scenario-a/api/v1/orders/${config.testOrderId}`,
        { 
          headers: createHeaders(),
          validateStatus: () => true // Accept any status
        }
      );
      
      expect(response.status).to.be.oneOf([200, 401, 403]); // 200 or auth error
    } else {
      this.skip(); // Skip if API Gateway not configured
    }
  });
});

/**
 * Test Execution Summary
 */
after(function() {
  console.log('\n=== Test Execution Summary ===');
  console.log(`Total tests: ${this.test.parent.tests.length}`);
  console.log(`Configuration:`);
  console.log(`  ERP Service: ${config.erpService}`);
  console.log(`  MES Service: ${config.mesService}`);
  console.log(`  QMS Service: ${config.qmsService}`);
  console.log(`  ACE Server: ${config.aceServer}`);
  console.log(`  API Gateway: ${config.apiGateway}`);
});

// Made with Bob
