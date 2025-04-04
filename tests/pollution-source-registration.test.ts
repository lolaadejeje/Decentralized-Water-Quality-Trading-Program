import { describe, it, expect, beforeEach } from 'vitest';
import { mockClaritySession } from './test-utils';

describe('Pollution Source Registration Contract', () => {
  let session;
  
  beforeEach(() => {
    session = mockClaritySession();
    // Initialize contract state
  });
  
  it('should register a new facility', async () => {
    const result = await session.callPublic('pollution-source-registration', 'register-facility', [
      'Facility A',
      'Location X',
      'Nitrogen',
      100
    ]);
    
    expect(result.success).toBe(true);
    expect(result.value).toBe(1); // First facility ID
    
    const facility = await session.callReadOnly('pollution-source-registration', 'get-facility', [1]);
    expect(facility.name).toBe('Facility A');
    expect(facility.baseline-emissions).toBe(100);
    expect(facility.active).toBe(true);
  });
  
  it('should update emissions for a facility', async () => {
    // First register a facility
    await session.callPublic('pollution-source-registration', 'register-facility', [
      'Facility A',
      'Location X',
      'Nitrogen',
      100
    ]);
    
    // Update emissions
    const result = await session.callPublic('pollution-source-registration', 'update-emissions', [1, 80]);
    expect(result.success).toBe(true);
    
    // Verify update
    const facility = await session.callReadOnly('pollution-source-registration', 'get-facility', [1]);
    expect(facility.baseline-emissions).toBe(80);
  });
  
  it('should deactivate a facility', async () => {
    // First register a facility
    await session.callPublic('pollution-source-registration', 'register-facility', [
      'Facility A',
      'Location X',
      'Nitrogen',
      100
    ]);
    
    // Deactivate facility
    const result = await session.callPublic('pollution-source-registration', 'deactivate-facility', [1]);
    expect(result.success).toBe(true);
    
    // Verify deactivation
    const facility = await session.callReadOnly('pollution-source-registration', 'get-facility', [1]);
    expect(facility.active).toBe(false);
  });
});
