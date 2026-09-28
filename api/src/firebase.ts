import { initializeApp } from 'firebase-admin/app';
import { getDataConnect } from 'firebase-admin/data-connect';
import { connectorConfig } from '@dataconnect/admin-generated';

// Inicializamos la app primero
export const app = initializeApp();

// Inicializamos el conector autogenerado de Firebase Data Connect
export const adminDc = getDataConnect(connectorConfig);
