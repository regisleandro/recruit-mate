import { apiRequest } from '$lib/utils/api';

export interface Company {
  id: string;
  name: string;
}

interface JSONAPIResource {
  id: string;
  type: string;
  attributes: {
    id: number;
    name: string;
  };
}

interface CompanyResponse {
  data: JSONAPIResource[];
}

interface CompanyDetailResponse {
  data: JSONAPIResource;
}

export async function getCompanies(): Promise<Company[]> {
  try {
    const response = await apiRequest<CompanyResponse>('/companies');

    // Transform the JSONAPI format to our Company interface
    return (response.data || []).map((item) => ({
      id: item.id,
      name: item.attributes.name
    }));
  } catch (error) {
    console.error('Error fetching companies:', error);
    throw error;
  }
}

export async function getCompany(id: string): Promise<Company> {
  try {
    const response = await apiRequest<CompanyDetailResponse>(
      `/companies/${id}`
    );

    // Transform the JSONAPI format to our Company interface
    return {
      id: response.data.id,
      name: response.data.attributes.name
    };
  } catch (error) {
    console.error(`Error fetching company ${id}:`, error);
    throw error;
  }
}

export async function createCompany(
  company: Omit<Company, 'id'>
): Promise<Company> {
  try {
    const response = await apiRequest<CompanyDetailResponse>('/companies', {
      method: 'POST',
      body: { company }
    });

    // Transform the JSONAPI format to our Company interface
    return {
      id: response.data.id,
      name: response.data.attributes.name
    };
  } catch (error) {
    console.error('Error creating company:', error);
    throw error;
  }
}

export async function updateCompany(
  id: string,
  company: Partial<Company>
): Promise<Company> {
  try {
    const response = await apiRequest<CompanyDetailResponse>(
      `/companies/${id}`,
      {
        method: 'PUT',
        body: { company }
      }
    );

    // Transform the JSONAPI format to our Company interface
    return {
      id: response.data.id,
      name: response.data.attributes.name
    };
  } catch (error) {
    console.error(`Error updating company ${id}:`, error);
    throw error;
  }
}

export async function deleteCompany(id: string): Promise<void> {
  try {
    await apiRequest(`/companies/${id}`, {
      method: 'DELETE'
    });
  } catch (error) {
    console.error(`Error deleting company ${id}:`, error);
    throw error;
  }
}
