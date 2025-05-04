import axios from 'axios';
import { API_URL } from '../utils/constants';

export interface WhatsAppBusinessConfig {
  id: number;
  access_token: string;
  phone_number_id: string;
  business_account_id: string;
  verify_token: string;
  recruiter_id: number;
  created_at: string;
  updated_at: string;
}

export interface WhatsAppBusinessConfigInput {
  access_token: string;
  phone_number_id: string;
  business_account_id: string;
  verify_token: string;
}

export interface TestMessageInput {
  phone_number: string;
  message: string;
}

export interface TestMessageResponse {
  success: boolean;
  message: string;
  message_id?: string;
}

export interface ErrorDetails {
  error: string;
  details?: unknown;
}

// Interface for API response structure
interface ApiResponseData {
  data: {
    id: string;
    type: string;
    attributes: {
      id: number;
      phone_number_id: string;
      business_account_id: string;
      access_token: string;
      verify_token: string;
      created_at: string;
      updated_at: string;
      [key: string]: unknown;
    };
    relationships?: {
      recruiter?: {
        data: {
          id: string;
          type: string;
        };
      };
      [key: string]: unknown;
    };
  };
}

// Convert JSONAPI response to our interface format
const convertJsonApiToConfig = (
  response: ApiResponseData
): WhatsAppBusinessConfig | null => {
  if (!response || !response.data) return null;

  const { data } = response;
  const attributes = data.attributes || {};

  return {
    id: attributes.id,
    access_token: attributes.access_token,
    phone_number_id: attributes.phone_number_id,
    business_account_id: attributes.business_account_id,
    verify_token: attributes.verify_token,
    recruiter_id: parseInt(data.relationships?.recruiter?.data?.id || '0'),
    created_at: attributes.created_at,
    updated_at: attributes.updated_at
  };
};

const whatsAppBusinessConfigService = {
  /**
   * Get the WhatsApp Business configuration for a specific recruiter
   */
  getConfig: async (
    recruiterId: string
  ): Promise<WhatsAppBusinessConfig | null> => {
    try {
      const response = await axios.get(
        `${API_URL}/api/v1/recruiters/${recruiterId}/whatsapp_business_config`
      );
      return convertJsonApiToConfig(response.data);
    } catch (error) {
      if (axios.isAxiosError(error) && error.response?.status === 404) {
        return null;
      }
      throw error;
    }
  },

  /**
   * Create a new WhatsApp Business configuration for a recruiter
   */
  createConfig: async (
    recruiterId: string,
    config: WhatsAppBusinessConfigInput
  ): Promise<WhatsAppBusinessConfig> => {
    const response = await axios.post(
      `${API_URL}/api/v1/recruiters/${recruiterId}/whatsapp_business_config`,
      {
        whats_app_business_config: config
      }
    );
    return convertJsonApiToConfig(response.data) as WhatsAppBusinessConfig;
  },

  /**
   * Update an existing WhatsApp Business configuration for a recruiter
   */
  updateConfig: async (
    recruiterId: string,
    config: WhatsAppBusinessConfigInput
  ): Promise<WhatsAppBusinessConfig> => {
    const response = await axios.put(
      `${API_URL}/api/v1/recruiters/${recruiterId}/whatsapp_business_config`,
      {
        whats_app_business_config: config
      }
    );
    return convertJsonApiToConfig(response.data) as WhatsAppBusinessConfig;
  },

  /**
   * Delete the WhatsApp Business configuration for a recruiter
   */
  deleteConfig: async (recruiterId: string): Promise<void> => {
    await axios.delete(
      `${API_URL}/api/v1/recruiters/${recruiterId}/whatsapp_business_config`
    );
  },

  /**
   * Send a test message using the WhatsApp Business configuration for a recruiter
   */
  sendTestMessage: async (
    recruiterId: string,
    params: TestMessageInput
  ): Promise<TestMessageResponse> => {
    const response = await axios.post(
      `${API_URL}/api/v1/recruiters/${recruiterId}/whatsapp_business_config/test_message`,
      params
    );
    return response.data;
  },

  /**
   * Generate a secure verify token using WebCrypto API
   */
  generateVerifyToken: (): string => {
    // Create a typed array of 32 bytes (256 bits)
    const randomBytes = new Uint8Array(32);

    // Fill with cryptographically secure random values
    if (window.crypto && window.crypto.getRandomValues) {
      window.crypto.getRandomValues(randomBytes);
    } else {
      // Fallback for older browsers (less secure)
      for (let i = 0; i < randomBytes.length; i++) {
        randomBytes[i] = Math.floor(Math.random() * 256);
      }
      console.warn('Using less secure random number generation.');
    }

    // Convert to hex string
    return Array.from(randomBytes)
      .map((b) => b.toString(16).padStart(2, '0'))
      .join('');
  }
};

export default whatsAppBusinessConfigService;
