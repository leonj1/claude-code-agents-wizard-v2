<objective>
Implement a user authentication system with JWT tokens for the application.
</objective>

<context>
This is for a Node.js backend API that needs secure user authentication.
The system should support user registration, login, and token-based authorization.
</context>

<requirements>
1. Create authentication endpoints (register, login, logout)
2. Implement JWT token generation and validation
3. Add password hashing using bcrypt
4. Create middleware for protecting routes
5. Add comprehensive tests for all authentication flows
6. Follow project coding standards
</requirements>

<implementation>
- Use industry-standard JWT libraries
- Store passwords securely with bcrypt (min 10 rounds)
- Token expiration: 24 hours
- Include refresh token mechanism
- Avoid storing sensitive data in tokens
</implementation>

<output>
Create/modify files:
- `./src/auth/auth.controller.js` - Authentication endpoints
- `./src/auth/auth.service.js` - Business logic
- `./src/auth/jwt.middleware.js` - JWT validation middleware
- `./tests/auth.test.js` - Comprehensive test suite
</output>

<verification>
Before declaring complete:
- All tests pass
- Code follows project standards
- No security vulnerabilities (SQL injection, XSS, etc.)
- JWT tokens properly signed and validated
</verification>

<success_criteria>
- User can register with email/password
- User can login and receive JWT token
- Protected routes require valid token
- All tests pass with 100% coverage on auth logic
</success_criteria>
