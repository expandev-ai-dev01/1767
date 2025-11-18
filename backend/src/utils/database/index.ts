/**
 * @summary
 * Database utility functions.
 * Provides database connection and query execution helpers.
 *
 * @module utils/database
 */

import sql from 'mssql';
import { config } from '@/config';

let pool: sql.ConnectionPool | null = null;

export enum ExpectedReturn {
  Single = 'Single',
  Multi = 'Multi',
  None = 'None',
}

export interface IRecordSet<T = any> {
  recordset: T[];
}

/**
 * @summary
 * Gets or creates database connection pool.
 *
 * @function getPool
 *
 * @returns {Promise<sql.ConnectionPool>} Database connection pool
 */
export async function getPool(): Promise<sql.ConnectionPool> {
  if (!pool) {
    pool = await sql.connect(config.database);
  }
  return pool;
}

/**
 * @summary
 * Replaces [dbo] schema with project-specific schema.
 *
 * @function replaceSchemaInRoutine
 *
 * @param {string} routine - Stored procedure name
 *
 * @returns {string} Routine with replaced schema
 */
function replaceSchemaInRoutine(routine: string): string {
  const projectId = config.project.id;

  if (!projectId) {
    return routine;
  }

  const projectSchema = `project_${projectId}`;
  let replaced = routine.replace(/\[dbo\]\./gi, `[${projectSchema}].`);
  replaced = replaced.replace(/\bdbo\./gi, `[${projectSchema}].`);

  return replaced;
}

/**
 * @summary
 * Executes database stored procedure with automatic schema replacement.
 *
 * @function dbRequest
 *
 * @param {string} routine - Stored procedure name
 * @param {Record<string, any>} parameters - Procedure parameters
 * @param {ExpectedReturn} expectedReturn - Expected return type
 * @param {sql.Transaction} transaction - Optional transaction
 * @param {string[]} resultSetNames - Optional result set names
 *
 * @returns {Promise<any>} Query results
 */
export async function dbRequest(
  routine: string,
  parameters: Record<string, any>,
  expectedReturn: ExpectedReturn,
  transaction?: sql.Transaction,
  resultSetNames?: string[]
): Promise<any> {
  const schemaReplacedRoutine = replaceSchemaInRoutine(routine);
  const connectionPool = transaction || (await getPool());
  const request = connectionPool.request();

  for (const [key, value] of Object.entries(parameters)) {
    request.input(key, value);
  }

  const result = await request.execute(schemaReplacedRoutine);

  if (expectedReturn === ExpectedReturn.None) {
    return null;
  }

  if (expectedReturn === ExpectedReturn.Single) {
    return result.recordset[0] || null;
  }

  if (expectedReturn === ExpectedReturn.Multi) {
    if (resultSetNames && resultSetNames.length > 0) {
      const namedResults: Record<string, any> = {};
      resultSetNames.forEach((name, index) => {
        namedResults[name] = result.recordsets[index] || [];
      });
      return namedResults;
    }
    return result.recordsets;
  }

  return result.recordset;
}

/**
 * @summary
 * Begins a database transaction.
 *
 * @function beginTransaction
 *
 * @returns {Promise<sql.Transaction>} Transaction object
 */
export async function beginTransaction(): Promise<sql.Transaction> {
  const connectionPool = await getPool();
  const transaction = new sql.Transaction(connectionPool);
  await transaction.begin();
  return transaction;
}

/**
 * @summary
 * Commits a database transaction.
 *
 * @function commitTransaction
 *
 * @param {sql.Transaction} transaction - Transaction to commit
 *
 * @returns {Promise<void>}
 */
export async function commitTransaction(transaction: sql.Transaction): Promise<void> {
  await transaction.commit();
}

/**
 * @summary
 * Rolls back a database transaction.
 *
 * @function rollbackTransaction
 *
 * @param {sql.Transaction} transaction - Transaction to rollback
 *
 * @returns {Promise<void>}
 */
export async function rollbackTransaction(transaction: sql.Transaction): Promise<void> {
  await transaction.rollback();
}
