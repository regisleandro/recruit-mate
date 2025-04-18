import { apiRequest } from '$lib/utils/api';

export interface Candidate {
  id: string;
  name: string;
  curriculum: string | null;
  curriculum_url: string | null;
  curriculum_summary: string;
  cellphone_number: string;
  cpf: string;
  created_at: string;
  updated_at: string;
}

interface JSONAPIResource {
  id: string;
  type: string;
  attributes: {
    id: number;
    name: string;
    curriculum_url: string | null;
    curriculum_summary: string;
    cellphone_number: string;
    cpf: string;
    created_at: string;
    updated_at: string;
  };
  relationships?: {
    user: {
      data: {
        id: string;
        type: string;
      };
    };
  };
}

interface CandidateResponse {
  data: JSONAPIResource[];
  included?: Array<{
    id: string;
    type: string;
    attributes: Record<string, unknown>;
  }>;
}

interface CandidateDetailResponse {
  data: JSONAPIResource;
  included?: Array<{
    id: string;
    type: string;
    attributes: Record<string, unknown>;
  }>;
}

function transformCandidate(resource: JSONAPIResource): Candidate {
  return {
    id: resource.id,
    name: resource.attributes.name,
    curriculum: null, // This is not returned by the API directly
    curriculum_url: resource.attributes.curriculum_url,
    curriculum_summary: resource.attributes.curriculum_summary,
    cellphone_number: resource.attributes.cellphone_number,
    cpf: resource.attributes.cpf,
    created_at: resource.attributes.created_at,
    updated_at: resource.attributes.updated_at
  };
}

export async function getCandidates(): Promise<Candidate[]> {
  try {
    const response = await apiRequest<CandidateResponse>('/candidates');

    return (response.data || []).map((item) => transformCandidate(item));
  } catch (error) {
    console.error('Error fetching candidates:', error);
    throw error;
  }
}

export async function getCandidate(id: string): Promise<Candidate> {
  try {
    const response = await apiRequest<CandidateDetailResponse>(
      `/candidates/${id}`
    );
    return transformCandidate(response.data);
  } catch (error) {
    console.error(`Error fetching candidate ${id}:`, error);
    throw error;
  }
}

export async function createCandidate(
  candidateData: Omit<
    Candidate,
    'id' | 'created_at' | 'updated_at' | 'curriculum_url'
  >,
  curriculumFile?: File
): Promise<Candidate> {
  try {
    // First, prepare the candidate data
    const payload: {
      candidate: {
        name: string;
        curriculum_summary: string;
        cellphone_number: string;
        cpf: string;
      };
    } = {
      candidate: {
        name: candidateData.name,
        curriculum_summary: candidateData.curriculum_summary,
        cellphone_number: candidateData.cellphone_number,
        cpf: candidateData.cpf
      }
    };

    // If a file is provided, add it to the payload
    if (curriculumFile) {
      return await uploadCandidateWithFile(payload, curriculumFile);
    } else {
      // No file provided, just create the candidate
      const response = await apiRequest<CandidateDetailResponse>(
        '/candidates',
        {
          method: 'POST',
          body: payload
        }
      );

      return transformCandidate(response.data);
    }
  } catch (error) {
    console.error('Error creating candidate:', error);
    throw error;
  }
}

export async function updateCandidate(
  id: string,
  candidateData: Partial<
    Omit<Candidate, 'id' | 'created_at' | 'updated_at' | 'curriculum_url'>
  >,
  curriculumFile?: File
): Promise<Candidate> {
  try {
    // First, prepare the candidate data
    const payload: {
      candidate: {
        name?: string;
        curriculum_summary?: string;
        cellphone_number?: string;
        cpf?: string;
      };
    } = {
      candidate: {}
    };

    if (candidateData.name !== undefined)
      payload.candidate.name = candidateData.name;
    if (candidateData.curriculum_summary !== undefined)
      payload.candidate.curriculum_summary = candidateData.curriculum_summary;
    if (candidateData.cellphone_number !== undefined)
      payload.candidate.cellphone_number = candidateData.cellphone_number;
    if (candidateData.cpf !== undefined)
      payload.candidate.cpf = candidateData.cpf;

    // If a file is provided, add it to the payload
    if (curriculumFile) {
      return await uploadCandidateWithFile(payload, curriculumFile, id);
    } else {
      // No file provided, just update the candidate
      const response = await apiRequest<CandidateDetailResponse>(
        `/candidates/${id}`,
        {
          method: 'PATCH',
          body: payload
        }
      );

      return transformCandidate(response.data);
    }
  } catch (error) {
    console.error(`Error updating candidate ${id}:`, error);
    throw error;
  }
}

export async function deleteCandidate(id: string): Promise<void> {
  try {
    await apiRequest(`/candidates/${id}`, {
      method: 'DELETE'
    });
  } catch (error) {
    console.error(`Error deleting candidate ${id}:`, error);
    throw error;
  }
}

// Helper function to upload a candidate with a file
async function uploadCandidateWithFile(
  payload: {
    candidate: {
      name?: string;
      curriculum_summary?: string;
      cellphone_number?: string;
      cpf?: string;
    };
    curriculum_file?: {
      filename: string;
      data: string;
    };
  },
  file: File,
  candidateId?: string
): Promise<Candidate> {
  // Check file size (max 5MB)
  if (file.size > 5 * 1024 * 1024) {
    throw new Error('File is too large (max 5MB)');
  }

  // Read file as base64
  const base64Data = await readFileAsBase64(file);

  // Add file data to payload
  payload.curriculum_file = {
    filename: file.name,
    data: base64Data
  };

  // Create or update the candidate
  const endpoint = candidateId ? `/candidates/${candidateId}` : '/candidates';
  const method = candidateId ? 'PATCH' : 'POST';

  const response = await apiRequest<CandidateDetailResponse>(endpoint, {
    method,
    body: payload
  });

  return transformCandidate(response.data);
}

// Helper function to read a file as base64
function readFileAsBase64(file: File): Promise<string> {
  return new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.readAsDataURL(file);
    reader.onload = () => {
      const result = reader.result as string;
      // Remove the data URL prefix (e.g., "data:application/pdf;base64,")
      const base64 = result.split(',')[1];
      resolve(base64);
    };
    reader.onerror = (error) => reject(error);
  });
}
