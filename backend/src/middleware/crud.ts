/**
 * @summary
 * CRUD controller middleware providing standardized request validation
 * and response formatting for API operations.
 *
 * @module middleware/crud
 */

import { Request } from 'express';
import { z } from 'zod';

interface SecurityRule {
  securable: string;
  permission: 'CREATE' | 'READ' | 'UPDATE' | 'DELETE';
}

interface ValidatedRequest {
  credential: {
    idAccount: number;
    idUser: number;
  };
  params: any;
}

/**
 * @summary
 * CRUD controller for handling common API operations.
 *
 * @class CrudController
 */
export class CrudController {
  private securityRules: SecurityRule[];

  constructor(securityRules: SecurityRule[]) {
    this.securityRules = securityRules;
  }

  /**
   * @summary
   * Validates request for CREATE operations.
   *
   * @param {Request} req - Express request object
   * @param {z.ZodSchema} schema - Zod validation schema
   *
   * @returns {Promise<[ValidatedRequest | null, any]>} Validation result
   */
  async create(req: Request, schema: z.ZodSchema): Promise<[ValidatedRequest | null, any]> {
    return this.validateRequest(req, schema, 'CREATE');
  }

  /**
   * @summary
   * Validates request for READ operations.
   *
   * @param {Request} req - Express request object
   * @param {z.ZodSchema} schema - Zod validation schema
   *
   * @returns {Promise<[ValidatedRequest | null, any]>} Validation result
   */
  async read(req: Request, schema: z.ZodSchema): Promise<[ValidatedRequest | null, any]> {
    return this.validateRequest(req, schema, 'READ');
  }

  /**
   * @summary
   * Validates request for UPDATE operations.
   *
   * @param {Request} req - Express request object
   * @param {z.ZodSchema} schema - Zod validation schema
   *
   * @returns {Promise<[ValidatedRequest | null, any]>} Validation result
   */
  async update(req: Request, schema: z.ZodSchema): Promise<[ValidatedRequest | null, any]> {
    return this.validateRequest(req, schema, 'UPDATE');
  }

  /**
   * @summary
   * Validates request for DELETE operations.
   *
   * @param {Request} req - Express request object
   * @param {z.ZodSchema} schema - Zod validation schema
   *
   * @returns {Promise<[ValidatedRequest | null, any]>} Validation result
   */
  async delete(req: Request, schema: z.ZodSchema): Promise<[ValidatedRequest | null, any]> {
    return this.validateRequest(req, schema, 'DELETE');
  }

  /**
   * @summary
   * Internal validation method.
   *
   * @param {Request} req - Express request object
   * @param {z.ZodSchema} schema - Zod validation schema
   * @param {string} operation - Operation type
   *
   * @returns {Promise<[ValidatedRequest | null, any]>} Validation result
   */
  private async validateRequest(
    req: Request,
    schema: z.ZodSchema,
    operation: string
  ): Promise<[ValidatedRequest | null, any]> {
    try {
      const params = { ...req.params, ...req.query, ...req.body };
      const validated = await schema.parseAsync(params);

      const result: ValidatedRequest = {
        credential: {
          idAccount: 1,
          idUser: 1,
        },
        params: validated,
      };

      return [result, null];
    } catch (error: any) {
      return [null, { statusCode: 400, message: 'Validation failed', details: error.errors }];
    }
  }
}

/**
 * @summary
 * Creates a success response object.
 *
 * @function successResponse
 *
 * @param {any} data - Response data
 * @param {any} metadata - Optional metadata
 *
 * @returns {object} Success response
 */
export function successResponse(data: any, metadata?: any) {
  return {
    success: true,
    data: data,
    metadata: metadata || { timestamp: new Date().toISOString() },
  };
}

/**
 * @summary
 * Creates an error response object.
 *
 * @function errorResponse
 *
 * @param {string} message - Error message
 * @param {string} code - Error code
 *
 * @returns {object} Error response
 */
export function errorResponse(message: string, code: string = 'ERROR') {
  return {
    success: false,
    error: {
      code: code,
      message: message,
    },
    timestamp: new Date().toISOString(),
  };
}

export const StatusGeneralError = {
  statusCode: 500,
  code: 'INTERNAL_SERVER_ERROR',
  message: 'An internal server error occurred',
};
