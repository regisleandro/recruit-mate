import { apiRequest } from '$lib/utils/api';
import type { Candidate } from './candidateService';
import type { Job } from './jobService';

export interface JobApplication {
  id: string;
  status: string;
  statusLabel: string;
  notes: string;
  candidateId: string;
  jobId: string;
  createdAt: string;
  updatedAt: string;
  candidate?: Candidate;
  job?: Job;
}

export const JobApplicationStatus = {
  PENDING: 'pending',
  REVIEWING: 'reviewing',
  PHONE_SCREEN: 'phone_screen',
  INTERVIEWING: 'interviewing',
  TECHNICAL_TEST: 'technical_test',
  REFERENCE_CHECK: 'reference_check',
  OFFERED: 'offered',
  ACCEPTED: 'accepted',
  REJECTED: 'rejected',
  WITHDRAWN: 'withdrawn'
};

export const JobApplicationStatusLabels: Record<string, string> = {
  [JobApplicationStatus.PENDING]: 'Pending',
  [JobApplicationStatus.REVIEWING]: 'Reviewing',
  [JobApplicationStatus.PHONE_SCREEN]: 'Phone Screen',
  [JobApplicationStatus.INTERVIEWING]: 'Interviewing',
  [JobApplicationStatus.TECHNICAL_TEST]: 'Technical Test',
  [JobApplicationStatus.REFERENCE_CHECK]: 'Reference Check',
  [JobApplicationStatus.OFFERED]: 'Offered',
  [JobApplicationStatus.ACCEPTED]: 'Accepted',
  [JobApplicationStatus.REJECTED]: 'Rejected',
  [JobApplicationStatus.WITHDRAWN]: 'Withdrawn'
};

interface JSONAPIResource {
  id: string;
  type: string;
  attributes: {
    id: number;
    status: string;
    notes: string;
    candidate_id: string;
    job_id: string;
    created_at: string;
    updated_at: string;
  };
  relationships?: {
    candidate: {
      data: {
        id: string;
        type: string;
      };
    };
    job: {
      data: {
        id: string;
        type: string;
      };
    };
  };
}

// Common type for included resources
interface IncludedResource {
  id: string;
  type: string;
  attributes: Record<string, unknown>;
}

interface JobApplicationResponse {
  data: JSONAPIResource[];
  included?: IncludedResource[];
}

interface JobApplicationDetailResponse {
  data: JSONAPIResource;
  included?: IncludedResource[];
}

function transformJobApplication(
  resource: JSONAPIResource,
  included?: IncludedResource[]
): JobApplication {
  const jobApplication: JobApplication = {
    id: resource.id,
    status: resource.attributes.status,
    statusLabel: JobApplicationStatusLabels[resource.attributes.status] || resource.attributes.status,
    notes: resource.attributes.notes,
    candidateId: resource.attributes.candidate_id,
    jobId: resource.attributes.job_id,
    createdAt: resource.attributes.created_at,
    updatedAt: resource.attributes.updated_at
  };

  if (included && resource.relationships) {
    if (resource.relationships.candidate) {
      const candidateData = included.find(
        (item) =>
          item.type === 'candidate' &&
          item.id === resource.relationships!.candidate.data.id
      );

      if (candidateData) {
        jobApplication.candidate = {
          id: candidateData.id,
          name: candidateData.attributes.name as string,
          curriculum: null,
          curriculum_url: candidateData.attributes.curriculum_url as string | null,
          curriculum_summary: candidateData.attributes.curriculum_summary as string,
          cellphone_number: candidateData.attributes.cellphone_number as string,
          cpf: candidateData.attributes.cpf as string,
          created_at: candidateData.attributes.created_at as string,
          updated_at: candidateData.attributes.updated_at as string
        };
      }
    }

    if (resource.relationships.job) {
      const jobData = included.find(
        (item) =>
          item.type === 'job' &&
          item.id === resource.relationships!.job.data.id
      );

      if (jobData) {
        jobApplication.job = {
          id: jobData.id,
          description: jobData.attributes.description as string,
          benefits: jobData.attributes.benefits as string,
          keywords: jobData.attributes.keywords as string,
          startTime: new Date(jobData.attributes.start_time as string),
          endTime: new Date(jobData.attributes.end_time as string),
          intervalTime: jobData.attributes.interval_time as number,
          status: jobData.attributes.status as string,
          statusLabel: jobData.attributes.status_label as string,
          prompt: jobData.attributes.prompt as string,
          companyId: jobData.attributes.company_id as string
        };
      }
    }
  }

  return jobApplication;
}

export async function getJobApplications(
  params: { jobId?: string; candidateId?: string; status?: string } = {}
): Promise<JobApplication[]> {
  try {
    let endpoint = '/job_applications';
    const queryParams: string[] = [];
    
    if (params.jobId) queryParams.push(`job_id=${params.jobId}`);
    if (params.candidateId) queryParams.push(`candidate_id=${params.candidateId}`);
    if (params.status) queryParams.push(`status=${params.status}`);
    
    if (queryParams.length > 0) {
      endpoint += `?${queryParams.join('&')}`;
    }
    
    const response = await apiRequest<JobApplicationResponse>(endpoint);

    return (response.data || []).map((item) =>
      transformJobApplication(item, response.included)
    );
  } catch (error) {
    console.error('Error fetching job applications:', error);
    throw error;
  }
}

export async function getJobApplication(id: string): Promise<JobApplication> {
  try {
    const response = await apiRequest<JobApplicationDetailResponse>(`/job_applications/${id}`);
    return transformJobApplication(response.data, response.included);
  } catch (error) {
    console.error(`Error fetching job application ${id}:`, error);
    throw error;
  }
}

export async function createJobApplication(
  jobApplication: {
    candidateId: string;
    jobId: string;
    status?: string;
    notes?: string;
  }
): Promise<JobApplication> {
  try {
    const payload = {
      job_application: {
        candidate_id: jobApplication.candidateId,
        job_id: jobApplication.jobId,
        status: jobApplication.status || JobApplicationStatus.PENDING,
        notes: jobApplication.notes || ''
      }
    };

    const response = await apiRequest<JobApplicationDetailResponse>('/job_applications', {
      method: 'POST',
      body: payload
    });

    return transformJobApplication(response.data, response.included);
  } catch (error) {
    console.error('Error creating job application:', error);
    throw error;
  }
}

export async function updateJobApplication(
  id: string,
  updates: {
    status?: string;
    notes?: string;
  }
): Promise<JobApplication> {
  try {
    const payload = {
      job_application: {
        status: updates.status,
        notes: updates.notes
      }
    };

    const response = await apiRequest<JobApplicationDetailResponse>(`/job_applications/${id}`, {
      method: 'PATCH',
      body: payload
    });

    return transformJobApplication(response.data, response.included);
  } catch (error) {
    console.error(`Error updating job application ${id}:`, error);
    throw error;
  }
}

export async function deleteJobApplication(id: string): Promise<void> {
  try {
    await apiRequest(`/job_applications/${id}`, {
      method: 'DELETE'
    });
  } catch (error) {
    console.error(`Error deleting job application ${id}:`, error);
    throw error;
  }
}

export async function addNote(
  id: string,
  note: string
): Promise<JobApplication> {
  try {
    const currentApp = await getJobApplication(id);
    const updatedNotes = currentApp.notes 
      ? `${currentApp.notes}\n---\n${new Date().toISOString()}\n${note}`
      : `${new Date().toISOString()}\n${note}`;
    
    return updateJobApplication(id, { notes: updatedNotes });
  } catch (error) {
    console.error(`Error adding note to job application ${id}:`, error);
    throw error;
  }
} 