import Elysia from "elysia";

import { authController } from './auth';
import { competitionController } from './competition';
import { facultyController } from './faculty';
import { messController } from './mess';
import { searchController } from './search';
import { shuttleController } from './shuttle';
import { SuccessEnvelope } from '../common/http';


export const apiRouter = new Elysia({ 
    name: "api", 
    prefix: "/api" 
}).get('/', () => {
			return SuccessEnvelope({ok: true}, 'CSquare Connect API is healthy')
	}, {
			detail: {
			summary: 'Health check endpoint',
			tags: ['General'],
			},
	})
	.use(authController)

	// Versioned API routes
	.group('/v1', (v1) =>
			v1
			.use(facultyController)
			.use(messController)
			.use(shuttleController)
			.use(competitionController)
			.use(searchController)
	);