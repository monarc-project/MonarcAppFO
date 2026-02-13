# MONARC API Documentation

This directory contains the OpenAPI specification and Swagger UI for the MONARC API.

## Files

- `swagger.yaml` - OpenAPI 3.0.0 specification describing all MONARC API endpoints
- `swagger-ui.html` - Web interface for viewing and interacting with the API documentation

## Accessing the API Documentation

### Option 1: View in Browser (Recommended for local installations)

If you have MONARC running locally, navigate to:
```
http://your-monarc-installation/swagger-ui.html
```

### Option 2: Download and Use Swagger Editor

1. Download the `swagger.yaml` file
2. Visit [Swagger Editor](https://editor.swagger.io/)
3. Import the `swagger.yaml` file

### Option 3: Use with API Clients

Import the `swagger.yaml` file into API testing tools:
- Postman
- Insomnia
- HTTPie
- Or any OpenAPI-compatible tool

## Authentication

Most API endpoints require authentication. To authenticate:

1. **Login**: Send a POST request to `/api/auth` with your credentials:
   ```json
   {
     "email": "your-email@example.com",
     "password": "your-password"
   }
   ```

2. **Use Token**: Include the returned token in subsequent requests using the `Token` header:
   ```
   Token: your-authentication-token
   ```

## API Endpoints Overview

The API is organized into the following categories:

- **Authentication** - User login and logout
- **Users** - User management (admin only)
- **Roles** - User role management
- **ANR** - Risk analysis management
- **Assets** - Asset management within analyses
- **Threats** - Threat management
- **Vulnerabilities** - Vulnerability management
- **Measures** - Control/measure management
- **Risks** - Risk assessment and management
- **Recommendations** - Recommendation management
- **Treatment Plan** - Risk treatment planning
- **SOA** - Statement of Applicability
- **Records (GDPR)** - Processing activities records
- **Instances** - Asset instances in risk analyses
- **Snapshots** - Analysis snapshots
- **Statistics** - Statistical data
- And many more...

## Base URL

All API endpoints are relative to your MONARC installation's base URL.

For example:
- Local: `http://localhost/api/...`
- Production: `https://your-domain.com/api/...`

## API Versioning

The current API version is documented in the `swagger.yaml` file (version 2.13.3 as of this update).

## Contributing

When adding new API endpoints:

1. Update the route configuration in `config/module.config.php`
2. Add the endpoint documentation to `public/swagger.yaml`
3. Ensure proper authentication and authorization are documented
4. Include request/response examples where applicable

## Support

For more information about MONARC:
- Website: https://www.monarc.lu
- Documentation: https://www.monarc.lu/documentation
- GitHub: https://github.com/monarc-project
