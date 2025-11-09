# Python Coding Standards

Python-specific coding standards and conventions.

## File Organization

### Module Structure
- **One class per file** (unless closely related helper classes)
- File name should match the main class name in snake_case
- Module-level constants at the top
- Imports organized: standard library, third-party, local

### Example
```python
# user_repository.py - contains UserRepository class
# database_connection.py - contains DatabaseConnection class
```

## Class Design

### Class Structure
```python
class UserRepository:
    """Class docstring explaining purpose."""
    
    # Class constants
    MAX_RETRIES = 3
    
    def __init__(self, db_connection, logger):
        """Initialize with dependencies - no defaults."""
        self.db_connection = db_connection
        self.logger = logger
    
    def find_user(self, user_id):
        """Public methods."""
        pass
    
    def _validate_user_id(self, user_id):
        """Private methods prefixed with underscore."""
        pass
```

### Key Rules
- One primary class per file
- Dependencies injected via `__init__`
- No default parameter values
- Use `@property` for computed attributes
- Use `@staticmethod` or `@classmethod` appropriately

## Function Design

### No Default Arguments
```python
# ❌ BAD - Default arguments
def create_user(name, email, role="user"):
    pass

# ✅ GOOD - Explicit arguments
def create_user(name, email, role):
    pass
```

### No Environment Variable Access
```python
# ❌ BAD - Reading env vars in function
def connect_to_database():
    host = os.getenv("DB_HOST")
    port = os.getenv("DB_PORT")
    return connect(host, port)

# ✅ GOOD - Configuration passed as arguments
def connect_to_database(host, port):
    return connect(host, port)

# Configuration read at startup
config = {
    "db_host": os.getenv("DB_HOST"),
    "db_port": os.getenv("DB_PORT")
}
db = connect_to_database(config["db_host"], config["db_port"])
```

### Type Hints
```python
from typing import List, Optional, Dict

def process_users(
    users: List[Dict[str, str]], 
    filter_active: bool
) -> List[Dict[str, str]]:
    """Always use type hints for function signatures."""
    pass
```

## Error Handling

### Custom Exceptions
```python
class UserNotFoundError(Exception):
    """Raised when user cannot be found."""
    pass

class ValidationError(Exception):
    """Raised when validation fails."""
    pass
```

### Error Propagation
```python
# ✅ GOOD - Let errors propagate
def get_user(user_id):
    user = repository.find(user_id)
    if not user:
        raise UserNotFoundError(f"User {user_id} not found")
    return user

# ❌ BAD - Silent failure
def get_user(user_id):
    try:
        return repository.find(user_id)
    except Exception:
        return None  # Don't hide errors!
```

## Configuration Management

### Startup Configuration
```python
# config.py
import os
from dataclasses import dataclass

@dataclass
class DatabaseConfig:
    """Configuration read once at startup."""
    host: str
    port: int
    username: str
    password: str
    
    @classmethod
    def from_env(cls):
        """Factory method to create from environment."""
        return cls(
            host=os.getenv("DB_HOST"),
            port=int(os.getenv("DB_PORT")),
            username=os.getenv("DB_USER"),
            password=os.getenv("DB_PASSWORD")
        )

# main.py
config = DatabaseConfig.from_env()
repository = UserRepository(config)
```

## Testing

### Testable Design
```python
# ✅ GOOD - Easy to test with dependency injection
class UserService:
    def __init__(self, repository, email_sender):
        self.repository = repository
        self.email_sender = email_sender
    
    def register_user(self, email, name):
        user = self.repository.create(email, name)
        self.email_sender.send_welcome(user)
        return user

# Test with mocks
def test_register_user():
    mock_repo = Mock()
    mock_sender = Mock()
    service = UserService(mock_repo, mock_sender)
    # ... test logic
```

## Code Style

### Formatting
- Use Black or similar formatter
- Line length: 88-100 characters
- 4 spaces for indentation
- 2 blank lines between top-level definitions

### Naming
- `snake_case` for functions, variables, modules
- `PascalCase` for classes
- `UPPER_SNAKE_CASE` for constants
- `_leading_underscore` for private methods

### Docstrings
```python
def calculate_total(items, tax_rate):
    """
    Calculate total price including tax.
    
    Args:
        items: List of item dictionaries with 'price' key
        tax_rate: Tax rate as decimal (e.g., 0.08 for 8%)
    
    Returns:
        Total price as float including tax
    
    Raises:
        ValueError: If tax_rate is negative
    """
    pass
```

## Imports

### Organization
```python
# Standard library
import os
import sys
from typing import List, Dict

# Third-party
import requests
from flask import Flask

# Local application
from .models import User
from .repositories import UserRepository
```

### Avoid
- `from module import *`
- Circular imports
- Importing at function level (unless necessary)
