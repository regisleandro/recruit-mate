import { apiRequest } from '$lib/utils/api';

export interface Recruiter {
  id: string;
  name: string;
  prompt: string;
  telegram_token?: string;
}

interface JSONAPIResource {
  id: string;
  type: string;
  attributes: {
    id: number;
    name: string;
    prompt: string;
    telegram_token?: string;
  };
}

interface RecruiterResponse {
  data: JSONAPIResource[];
}

interface RecruiterDetailResponse {
  data: JSONAPIResource;
}

export async function getRecruiters(): Promise<Recruiter[]> {
  try {
    const response = await apiRequest<RecruiterResponse>('/recruiters');

    // Transform the JSONAPI format to our Recruiter interface
    return (response.data || []).map((item) => ({
      id: item.id,
      name: item.attributes.name,
      prompt: item.attributes.prompt,
      telegram_token: item.attributes.telegram_token
    }));
  } catch (error) {
    console.error('Error fetching recruiters:', error);
    throw error;
  }
}

export async function getRecruiter(id: string): Promise<Recruiter> {
  try {
    const response = await apiRequest<RecruiterDetailResponse>(
      `/recruiters/${id}`
    );

    // Transform the JSONAPI format to our Recruiter interface
    return {
      id: response.data.id,
      name: response.data.attributes.name,
      prompt: response.data.attributes.prompt,
      telegram_token: response.data.attributes.telegram_token
    };
  } catch (error) {
    console.error(`Error fetching recruiter ${id}:`, error);
    throw error;
  }
}

export async function createRecruiter(
  recruiter: Omit<Recruiter, 'id'>
): Promise<Recruiter> {
  try {
    const response = await apiRequest<RecruiterDetailResponse>('/recruiters', {
      method: 'POST',
      body: { recruiter }
    });

    // Transform the JSONAPI format to our Recruiter interface
    return {
      id: response.data.id,
      name: response.data.attributes.name,
      prompt: response.data.attributes.prompt,
      telegram_token: response.data.attributes.telegram_token
    };
  } catch (error) {
    console.error('Error creating recruiter:', error);
    throw error;
  }
}

export async function updateRecruiter(
  id: string,
  recruiter: Partial<Recruiter>
): Promise<Recruiter> {
  try {
    const response = await apiRequest<RecruiterDetailResponse>(
      `/recruiters/${id}`,
      {
        method: 'PUT',
        body: { recruiter }
      }
    );

    // Transform the JSONAPI format to our Recruiter interface
    return {
      id: response.data.id,
      name: response.data.attributes.name,
      prompt: response.data.attributes.prompt,
      telegram_token: response.data.attributes.telegram_token
    };
  } catch (error) {
    console.error(`Error updating recruiter ${id}:`, error);
    throw error;
  }
}

export async function deleteRecruiter(id: string): Promise<void> {
  try {
    await apiRequest(`/recruiters/${id}`, {
      method: 'DELETE'
    });
  } catch (error) {
    console.error(`Error deleting recruiter ${id}:`, error);
    throw error;
  }
}
