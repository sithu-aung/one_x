import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:one_x/core/constants/app_constants.dart';
import 'package:one_x/core/services/navigation_service.dart';
import 'package:one_x/core/services/storage_service.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? errors;

  ApiException(this.message, {this.statusCode, this.errors});

  @override
  String toString() => 'ApiException: $message (Status code: $statusCode)';
}

class NetworkException implements Exception {
  final String message;

  NetworkException(this.message);

  @override
  String toString() => 'NetworkException: $message';
}

class ApiService {
  final http.Client _httpClient;
  final StorageService _storageService;

  ApiService({http.Client? httpClient, required StorageService storageService})
    : _httpClient = httpClient ?? http.Client(),
      _storageService = storageService;

  // Headers for authenticated requests
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _storageService.getAuthToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Headers for public requests (no auth)
  Map<String, String> get _publicHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // GET request with authentication
  Future<dynamic> get(String endpoint) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await _httpClient
          .get(Uri.parse('${AppConstants.baseUrl}$endpoint'), headers: headers)
          .timeout(const Duration(seconds: 30));
      return _handleResponse(response);
    } on SocketException {
      const message = 'No internet connection';
      NavigationService.showSnackBar(message: message);
      throw NetworkException(message);
    } on HttpException {
      const message = 'Could not find the requested resource';
      NavigationService.showSnackBar(message: message);
      throw NetworkException(message);
    } on FormatException {
      const message = 'Bad response format';
      NavigationService.showSnackBar(message: message);
      throw NetworkException(message);
    } on TimeoutException {
      const message = 'Request timeout';
      NavigationService.showSnackBar(message: message);
      throw NetworkException(message);
    } catch (e) {
      // If it's already an ApiException, don't wrap it again
      if (e is ApiException) {
        // The error message will already be shown by the code that threw the ApiException
        rethrow;
      } else {
        final message = 'Failed to fetch data: $e';
        NavigationService.showSnackBar(message: message);
        throw ApiException(message);
      }
    }
  }

  // POST request with authentication
  Future<dynamic> post(String endpoint, {Map<String, dynamic>? body}) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await _httpClient
          .post(
            Uri.parse('${AppConstants.baseUrl}$endpoint'),
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(const Duration(seconds: 30));
      return _handleResponse(response);
    } on SocketException {
      const message = 'No internet connection';
      NavigationService.showSnackBar(message: message);
      throw NetworkException(message);
    } on HttpException {
      const message = 'Could not find the requested resource';
      NavigationService.showSnackBar(message: message);
      throw NetworkException(message);
    } on FormatException {
      const message = 'Bad response format';
      NavigationService.showSnackBar(message: message);
      throw NetworkException(message);
    } on TimeoutException {
      const message = 'Request timeout';
      NavigationService.showSnackBar(message: message);
      throw NetworkException(message);
    } catch (e) {
      // If it's already an ApiException, don't wrap it again
      if (e is ApiException) {
        // The error message will already be shown by the code that threw the ApiException
        rethrow;
      } else {
        final message = 'Failed to post data: $e';
        NavigationService.showSnackBar(message: message);
        throw ApiException(message);
      }
    }
  }

  // PUT request with authentication
  Future<dynamic> put(String endpoint, {Map<String, dynamic>? body}) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await _httpClient
          .put(
            Uri.parse('${AppConstants.baseUrl}$endpoint'),
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(const Duration(seconds: 30));
      return _handleResponse(response);
    } on SocketException {
      const message = 'No internet connection';
      NavigationService.showSnackBar(message: message);
      throw NetworkException(message);
    } on HttpException {
      const message = 'Could not find the requested resource';
      NavigationService.showSnackBar(message: message);
      throw NetworkException(message);
    } on FormatException {
      const message = 'Bad response format';
      NavigationService.showSnackBar(message: message);
      throw NetworkException(message);
    } on TimeoutException {
      const message = 'Request timeout';
      NavigationService.showSnackBar(message: message);
      throw NetworkException(message);
    } catch (e) {
      // If it's already an ApiException, don't wrap it again
      if (e is ApiException) {
        // The error message will already be shown by the code that threw the ApiException
        rethrow;
      } else {
        final message = 'Failed to update data: $e';
        NavigationService.showSnackBar(message: message);
        throw ApiException(message);
      }
    }
  }

  // DELETE request with authentication
  Future<dynamic> delete(String endpoint) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await _httpClient
          .delete(
            Uri.parse('${AppConstants.baseUrl}$endpoint'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 30));
      return _handleResponse(response);
    } on SocketException {
      const message = 'No internet connection';
      NavigationService.showSnackBar(message: message);
      throw NetworkException(message);
    } on HttpException {
      const message = 'Could not find the requested resource';
      NavigationService.showSnackBar(message: message);
      throw NetworkException(message);
    } on FormatException {
      const message = 'Bad response format';
      NavigationService.showSnackBar(message: message);
      throw NetworkException(message);
    } on TimeoutException {
      const message = 'Request timeout';
      NavigationService.showSnackBar(message: message);
      throw NetworkException(message);
    } catch (e) {
      // If it's already an ApiException, don't wrap it again
      if (e is ApiException) {
        // The error message will already be shown by the code that threw the ApiException
        rethrow;
      } else {
        final message = 'Failed to delete data: $e';
        NavigationService.showSnackBar(message: message);
        throw ApiException(message);
      }
    }
  }

  // Public POST request (no auth required, e.g., login, register)
  Future<dynamic> publicPost(
    String endpoint, {
    Map<String, dynamic>? body,
    bool returnStatusCode = false,
  }) async {
    try {
      final response = await _httpClient
          .post(
            Uri.parse('${AppConstants.baseUrl}$endpoint'),
            headers: _publicHeaders,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(const Duration(seconds: 30));

      // If returnStatusCode is true, return both status code and data
      if (returnStatusCode) {
        // For successful responses
        if (response.statusCode >= 200 && response.statusCode < 300) {
          if (response.body.isEmpty) {
            return {'statusCode': response.statusCode, 'data': null};
          }
          return {
            'statusCode': response.statusCode,
            'data': jsonDecode(response.body),
          };
        }
        // For error responses
        else {
          try {
            return {
              'statusCode': response.statusCode,
              'data': jsonDecode(response.body),
            };
          } catch (e) {
            return {
              'statusCode': response.statusCode,
              'data': {'message': response.reasonPhrase ?? 'Unknown error'},
            };
          }
        }
      }

      // Original behavior when returnStatusCode is false
      // For registration and other public endpoints, don't navigate to error page
      // Just return the response or throw the exception for the calling code to handle
      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isEmpty) return null;
        return jsonDecode(response.body);
      } else if (response.statusCode == 422) {
        // Validation errors - display in SnackBar if message is present
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['message'] ?? 'Validation failed';
        final errors = errorData['errors'] as Map<String, dynamic>?;

        // Display the most specific error message available
        String messageToDisplay = '';

        // Check for specific error cases first
        if (errors != null) {
          if (errors.containsKey('phone') &&
              errors['phone'] is List &&
              errors['phone'].isNotEmpty) {
            final phoneError = errors['phone'][0].toString();
            if (phoneError.contains('already been taken')) {
              messageToDisplay =
                  'This phone number is already registered. Please use a different phone number or login to your existing account.';
            }
          }
        }

        // If no specific case matched, use generic handling
        if (messageToDisplay.isEmpty) {
          // First priority: use the top-level message if it's specific enough
          if (errorMessage.isNotEmpty && errorMessage != 'Validation failed') {
            messageToDisplay = errorMessage;
          }
          // Second priority: use the first specific error message from the errors map
          else if (errors != null && errors.isNotEmpty) {
            // Get the first error message
            String firstErrorMessage = '';
            errors.forEach((field, messages) {
              if (firstErrorMessage.isEmpty) {
                if (messages is List && messages.isNotEmpty) {
                  firstErrorMessage = messages.first.toString();
                } else if (messages is String) {
                  firstErrorMessage = messages;
                }
              }
            });

            if (firstErrorMessage.isNotEmpty) {
              messageToDisplay = firstErrorMessage;
            }
          }
        }

        // If we have a message to display, show it
        if (messageToDisplay.isNotEmpty) {
          NavigationService.showSnackBar(message: messageToDisplay);
        } else {
          // Fallback to generic validation message
          NavigationService.showSnackBar(message: 'Validation failed');
        }

        throw ApiException(
          errorMessage,
          statusCode: response.statusCode,
          errors: errors,
        );
      } else {
        // For other errors, use the standard error handling
        return _handleResponse(response);
      }
    } on SocketException {
      const message = 'No internet connection';
      NavigationService.showSnackBar(message: message);
      throw NetworkException(message);
    } on HttpException {
      const message = 'Could not find the requested resource';
      NavigationService.showSnackBar(message: message);
      throw NetworkException(message);
    } on FormatException {
      const message = 'Bad response format';
      NavigationService.showSnackBar(message: message);
      throw NetworkException(message);
    } on TimeoutException {
      const message = 'Request timeout';
      NavigationService.showSnackBar(message: message);
      throw NetworkException(message);
    } on ApiException {
      // Re-throw API exceptions without showing a duplicate message
      rethrow;
    } catch (e) {
      final message = 'Failed to post data: $e';
      NavigationService.showSnackBar(message: message);
      throw ApiException(message);
    }
  }

  // Public GET request (no auth required)
  Future<dynamic> publicGet(String endpoint) async {
    try {
      final response = await _httpClient
          .get(
            Uri.parse('${AppConstants.baseUrl}$endpoint'),
            headers: _publicHeaders,
          )
          .timeout(const Duration(seconds: 30));

      // For public endpoints, don't navigate to error page
      // Just return the response or throw the exception for the calling code to handle
      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isEmpty) return null;
        return jsonDecode(response.body);
      } else if (response.statusCode == 422) {
        // Validation errors - display in SnackBar if message is present
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['message'] ?? 'Validation failed';
        final errors = errorData['errors'] as Map<String, dynamic>?;

        // Display the most specific error message available
        String messageToDisplay = '';

        // Check for specific error cases first
        if (errors != null) {
          if (errors.containsKey('phone') &&
              errors['phone'] is List &&
              errors['phone'].isNotEmpty) {
            final phoneError = errors['phone'][0].toString();
            if (phoneError.contains('already been taken')) {
              messageToDisplay =
                  'This phone number is already registered. Please use a different phone number or login to your existing account.';
            }
          }
        }

        // If no specific case matched, use generic handling
        if (messageToDisplay.isEmpty) {
          // First priority: use the top-level message if it's specific enough
          if (errorMessage.isNotEmpty && errorMessage != 'Validation failed') {
            messageToDisplay = errorMessage;
          }
          // Second priority: use the first specific error message from the errors map
          else if (errors != null && errors.isNotEmpty) {
            // Get the first error message
            String firstErrorMessage = '';
            errors.forEach((field, messages) {
              if (firstErrorMessage.isEmpty) {
                if (messages is List && messages.isNotEmpty) {
                  firstErrorMessage = messages.first.toString();
                } else if (messages is String) {
                  firstErrorMessage = messages;
                }
              }
            });

            if (firstErrorMessage.isNotEmpty) {
              messageToDisplay = firstErrorMessage;
            }
          }
        }

        // If we have a message to display, show it
        if (messageToDisplay.isNotEmpty) {
          NavigationService.showSnackBar(message: messageToDisplay);
        } else {
          // Fallback to generic validation message
          NavigationService.showSnackBar(message: 'Validation failed');
        }

        throw ApiException(
          errorMessage,
          statusCode: response.statusCode,
          errors: errors,
        );
      } else {
        // For other errors, use the standard error handling
        return _handleResponse(response);
      }
    } on SocketException {
      const message = 'No internet connection';
      NavigationService.showSnackBar(message: message);
      throw NetworkException(message);
    } on HttpException {
      const message = 'Could not find the requested resource';
      NavigationService.showSnackBar(message: message);
      throw NetworkException(message);
    } on FormatException {
      const message = 'Bad response format';
      NavigationService.showSnackBar(message: message);
      throw NetworkException(message);
    } on TimeoutException {
      const message = 'Request timeout';
      NavigationService.showSnackBar(message: message);
      throw NetworkException(message);
    } on ApiException {
      // Re-throw API exceptions without showing a duplicate message
      rethrow;
    } catch (e) {
      final message = 'Failed to fetch data: $e';
      NavigationService.showSnackBar(message: message);
      throw ApiException(message);
    }
  }

  // Handle API response
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      final errorData = _parseErrorData(response);
      final errorMessage = errorData?['message'] ?? 'Unauthorized';
      print('API 401 Unauthorized error: $errorMessage');

      // For login endpoint, just throw the exception so it can be handled by the login screen
      final requestUrl = response.request?.url.toString() ?? '';
      if (requestUrl.contains(AppConstants.loginEndpoint)) {
        throw ApiException(errorMessage, statusCode: response.statusCode);
      }

      // For other endpoints, clear auth token and navigate to login
      _storageService.clearAuthData();

      // Show message in SnackBar if present
      if (errorMessage.isNotEmpty) {
        NavigationService.showSnackBar(message: errorMessage);
      }

      // Navigate to login page
      NavigationService.navigateToLogin();

      throw ApiException(errorMessage, statusCode: response.statusCode);
    } else if (response.statusCode == 422) {
      // Validation errors
      try {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['message'] ?? 'Validation failed';
        final errors = errorData['errors'] as Map<String, dynamic>?;

        // For login endpoint, just throw the exception so it can be handled by the login screen
        final requestUrl = response.request?.url.toString() ?? '';
        if (requestUrl.contains(AppConstants.loginEndpoint)) {
          throw ApiException(
            errorMessage,
            statusCode: response.statusCode,
            errors: errors,
          );
        }

        // Display the most specific error message available
        String messageToDisplay = '';

        // Check for specific error cases first
        if (errors != null) {
          if (errors.containsKey('phone') &&
              errors['phone'] is List &&
              errors['phone'].isNotEmpty) {
            final phoneError = errors['phone'][0].toString();
            if (phoneError.contains('already been taken')) {
              messageToDisplay =
                  'This phone number is already registered. Please use a different phone number or login to your existing account.';
            }
          }
        }

        // If no specific case matched, use generic handling
        if (messageToDisplay.isEmpty) {
          // First priority: use the top-level message if it's specific enough
          if (errorMessage.isNotEmpty && errorMessage != 'Validation failed') {
            messageToDisplay = errorMessage;
          }
          // Second priority: use the first specific error message from the errors map
          else if (errors != null && errors.isNotEmpty) {
            // Get the first error message
            String firstErrorMessage = '';
            errors.forEach((field, messages) {
              if (firstErrorMessage.isEmpty) {
                if (messages is List && messages.isNotEmpty) {
                  firstErrorMessage = messages.first.toString();
                } else if (messages is String) {
                  firstErrorMessage = messages;
                }
              }
            });

            if (firstErrorMessage.isNotEmpty) {
              messageToDisplay = firstErrorMessage;
            }
          }
        }

        // If we have a message to display, show it
        if (messageToDisplay.isNotEmpty) {
          NavigationService.showSnackBar(message: messageToDisplay);
        } else {
          // Fallback to generic validation message
          NavigationService.showSnackBar(message: 'Validation failed');
        }

        throw ApiException(
          errorMessage,
          statusCode: response.statusCode,
          errors: errors,
        );
      } catch (e) {
        NavigationService.showSnackBar(message: 'Validation failed');
        throw ApiException(
          'Validation failed',
          statusCode: response.statusCode,
        );
      }
    } else if (response.statusCode == 404) {
      final errorData = _parseErrorData(response);
      final errorMessage = errorData?['message'] ?? 'Resource not found';
      NavigationService.showSnackBar(message: errorMessage);
      throw ApiException(errorMessage, statusCode: response.statusCode);
    } else if (response.statusCode == 403) {
      final errorData = _parseErrorData(response);
      final errorMessage = errorData?['message'] ?? 'Forbidden';
      NavigationService.showSnackBar(message: errorMessage);
      throw ApiException(errorMessage, statusCode: response.statusCode);
    } else if (response.statusCode == 500) {
      final errorData = _parseErrorData(response);
      final errorMessage = errorData?['message'] ?? 'Server error';
      NavigationService.showSnackBar(message: errorMessage);
      throw ApiException(errorMessage, statusCode: response.statusCode);
    } else {
      try {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['message'] ?? 'Unknown error occurred';
        final errors = errorData['errors'] as Map<String, dynamic>?;

        // Display the most specific error message available
        String messageToDisplay = '';

        // First priority: use the top-level message if it exists
        if (errorMessage.isNotEmpty &&
            errorMessage != 'Unknown error occurred') {
          messageToDisplay = errorMessage;
        }
        // Second priority: use the first specific error message from the errors map
        else if (errors != null && errors.isNotEmpty) {
          // Get the first error message
          String firstErrorMessage = '';
          errors.forEach((field, messages) {
            if (firstErrorMessage.isEmpty) {
              if (messages is List && messages.isNotEmpty) {
                firstErrorMessage = messages.first.toString();
              } else if (messages is String) {
                firstErrorMessage = messages;
              }
            }
          });

          if (firstErrorMessage.isNotEmpty) {
            messageToDisplay = firstErrorMessage;
          }
        }

        // If we have a message to display, show it
        if (messageToDisplay.isNotEmpty) {
          NavigationService.showSnackBar(message: messageToDisplay);
        } else {
          // Fallback to generic message
          NavigationService.showSnackBar(message: 'An error occurred');
        }

        throw ApiException(
          errorMessage,
          statusCode: response.statusCode,
          errors: errors,
        );
      } catch (e) {
        final message = 'Error: ${response.reasonPhrase}';
        NavigationService.showSnackBar(message: message);
        throw ApiException(message, statusCode: response.statusCode);
      }
    }
  }

  // Helper method to safely parse error data from response
  Map<String, dynamic>? _parseErrorData(http.Response response) {
    try {
      if (response.body.isNotEmpty) {
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic>) {
          return data;
        }
      }
      return null;
    } catch (e) {
      print('Error parsing response body: $e');
      return null;
    }
  }

  // Upload profile photo with multipart request
  Future<dynamic> uploadProfilePhoto(File profilePhoto) async {
    try {
      final uri = Uri.parse('${AppConstants.baseUrl}/api/user/profile/photo');
      final headers = await _getAuthHeaders();

      // Create a new multipart request
      final request = http.MultipartRequest('POST', uri);

      // Add headers (except Content-Type which is set automatically for multipart)
      headers.forEach((key, value) {
        if (key != 'Content-Type') {
          request.headers[key] = value;
        }
      });

      // Add the file
      request.files.add(
        await http.MultipartFile.fromPath('profile_photo', profilePhoto.path),
      );

      // Send the request
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
      );
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response);
    } on SocketException {
      const message = 'No internet connection';
      NavigationService.showSnackBar(message: message);
      throw NetworkException(message);
    } on HttpException {
      const message = 'Could not find the requested resource';
      NavigationService.showSnackBar(message: message);
      throw NetworkException(message);
    } on FormatException {
      const message = 'Bad response format';
      NavigationService.showSnackBar(message: message);
      throw NetworkException(message);
    } on TimeoutException {
      const message = 'Request timeout';
      NavigationService.showSnackBar(message: message);
      throw NetworkException(message);
    } catch (e) {
      // If it's already an ApiException, don't wrap it again
      if (e is ApiException) {
        // The error message will already be shown by the code that threw the ApiException
        rethrow;
      } else {
        final message = 'Failed to upload profile photo: $e';
        NavigationService.showSnackBar(message: message);
        throw ApiException(message);
      }
    }
  }
}
