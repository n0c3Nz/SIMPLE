# API Documentation

## Overview

This document provides detailed information about the API endpoints used in the SIMPLE project. The API allows for retrieving memory usage statistics and other related data.

## Endpoints

### 1. Get System Used Memory

- **Endpoint:** `/api/memory/used`
- **Method:** GET
- **Description:** Retrieves the total amount of used memory in GB.
- **Response:**
  ```json
  {
    "usedMemory": 8.5
  }
  ```

### 2. Get System Wired Memory

- **Endpoint:** `/api/memory/wired`
- **Method:** GET
- **Description:** Retrieves the total amount of wired memory in GB.
- **Response:**
  ```json
  {
    "wiredMemory": 2.3
  }
  ```

### 3. Get Cache Memory

- **Endpoint:** `/api/memory/cache`
- **Method:** GET
- **Description:** Retrieves the total amount of cache memory in GB.
- **Response:**
  ```json
  {
    "cacheMemory": 1.2
  }
  ```

### 4. Get Swap Memory

- **Endpoint:** `/api/memory/swap`
- **Method:** GET
- **Description:** Retrieves the total amount of swap memory in MB.
- **Response:**
  ```json
  {
    "swapMemory": 512
  }
  ```

### 5. Get App Memory

- **Endpoint:** `/api/memory/app`
- **Method:** GET
- **Description:** Retrieves the total amount of memory used by applications in GB.
- **Response:**
  ```json
  {
    "appMemory": 4.7
  }
  ```

### 6. Get Compressed Memory

- **Endpoint:** `/api/memory/compressed`
- **Method:** GET
- **Description:** Retrieves the total amount of compressed memory in GB.
- **Response:**
  ```json
  {
    "compressedMemory": 1.1
  }
  ```

### 7. Get Total Memory

- **Endpoint:** `/api/memory/total`
- **Method:** GET
- **Description:** Retrieves the total amount of physical memory in GB.
- **Response:**
  ```json
  {
    "totalMemory": 16.0
  }
  ```

## Examples

### Example Request

```sh
curl -X GET http://localhost:8080/api/memory/used
```

### Example Response

```json
{
  "usedMemory": 8.5
}
```
