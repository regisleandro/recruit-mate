import { apiRequest } from '$lib/utils/api';
import type { Company } from './companyService';

export interface Job {
  id: string;
  description: string;
  benefits: string;
  keywords: string;
  startTime: Date;
  endTime: Date;
  intervalTime: number;
  status: string;
  statusLabel: string;
  prompt: string;
  companyId: string;
  company?: Company;
}

interface JSONAPIResource {
  id: string;
  type: string;
  attributes: {
    id: number;
    description: string;
    benefits: string;
    keywords: string;
    start_time: string;
    end_time: string;
    interval_time: number;
    status: string;
    status_label: string;
    prompt: string;
    company_id: string;
    created_at: string;
    updated_at: string;
  };
  relationships?: {
    company: {
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

interface JobResponse {
  data: JSONAPIResource[];
  included?: IncludedResource[];
}

interface JobDetailResponse {
  data: JSONAPIResource;
  included?: IncludedResource[];
}

function transformJob(
  resource: JSONAPIResource,
  included?: IncludedResource[]
): Job {
  const job: Job = {
    id: resource.id,
    description: resource.attributes.description,
    benefits: resource.attributes.benefits,
    keywords: resource.attributes.keywords,
    startTime: new Date(resource.attributes.start_time),
    endTime: new Date(resource.attributes.end_time),
    intervalTime: resource.attributes.interval_time,
    status: resource.attributes.status,
    statusLabel: resource.attributes.status_label,
    prompt: resource.attributes.prompt,
    companyId: resource.attributes.company_id
  };

  if (included && resource.relationships && resource.relationships.company) {
    const companyData = included.find(
      (item) =>
        item.type === 'company' &&
        item.id === resource.relationships!.company.data.id
    );

    if (companyData) {
      job.company = {
        id: companyData.id,
        name: companyData.attributes.name as string
      };
    }
  }

  return job;
}

export async function getJobs(companyId?: string): Promise<Job[]> {
  try {
    const endpoint = companyId ? `/companies/${companyId}/jobs` : '/jobs';
    const response = await apiRequest<JobResponse>(endpoint);

    return (response.data || []).map((item) =>
      transformJob(item, response.included)
    );
  } catch (error) {
    console.error('Error fetching jobs:', error);
    throw error;
  }
}

export async function getJob(id: string): Promise<Job> {
  try {
    const response = await apiRequest<JobDetailResponse>(`/jobs/${id}`);
    return transformJob(response.data, response.included);
  } catch (error) {
    console.error(`Error fetching job ${id}:`, error);
    throw error;
  }
}

export async function createJob(
  job: Omit<Job, 'id' | 'statusLabel'>
): Promise<Job> {
  try {
    // Transform frontend format to API format
    const jobData = {
      description: job.description,
      benefits: job.benefits,
      keywords: job.keywords,
      start_time: job.startTime.toISOString(),
      end_time: job.endTime.toISOString(),
      interval_time: job.intervalTime,
      status: job.status,
      prompt: job.prompt,
      company_id: job.companyId
    };

    const response = await apiRequest<JobDetailResponse>('/jobs', {
      method: 'POST',
      body: { job: jobData }
    });

    return transformJob(response.data, response.included);
  } catch (error) {
    console.error('Error creating job:', error);
    throw error;
  }
}

export async function updateJob(
  id: string,
  job: Partial<Omit<Job, 'id' | 'companyId' | 'statusLabel'>>
): Promise<Job> {
  try {
    // Transform frontend format to API format
    const jobData: {
      description?: string;
      benefits?: string;
      keywords?: string;
      start_time?: string;
      end_time?: string;
      interval_time?: number;
      status?: string;
      prompt?: string;
    } = {};

    if (job.description !== undefined) jobData.description = job.description;
    if (job.benefits !== undefined) jobData.benefits = job.benefits;
    if (job.keywords !== undefined) jobData.keywords = job.keywords;
    if (job.startTime !== undefined)
      jobData.start_time = job.startTime.toISOString();
    if (job.endTime !== undefined) jobData.end_time = job.endTime.toISOString();
    if (job.intervalTime !== undefined)
      jobData.interval_time = job.intervalTime;
    if (job.status !== undefined) jobData.status = job.status;
    if (job.prompt !== undefined) jobData.prompt = job.prompt;

    const response = await apiRequest<JobDetailResponse>(`/jobs/${id}`, {
      method: 'PUT',
      body: { job: jobData }
    });

    return transformJob(response.data, response.included);
  } catch (error) {
    console.error(`Error updating job ${id}:`, error);
    throw error;
  }
}

export async function deleteJob(id: string): Promise<void> {
  try {
    await apiRequest(`/jobs/${id}`, {
      method: 'DELETE'
    });
  } catch (error) {
    console.error(`Error deleting job ${id}:`, error);
    throw error;
  }
}

export const JobStatus = {
  DRAFT: 'draft',
  OPEN: 'open',
  ON_HOLD: 'on_hold',
  IN_REVIEW: 'in_review',
  INTERVIEWING: 'interviewing',
  OFFER_EXTENDED: 'offer_extended',
  OFFER_ACCEPTED: 'offer_accepted',
  CLOSED: 'closed',
  ARCHIVED: 'archived',
  OFFER_DECLINED: 'offer_declined',
  REOPENED: 'reopened',
  CANCELLED: 'cancelled'
};

export const JobStatusLabels: Record<string, string> = {
  [JobStatus.DRAFT]: 'Draft',
  [JobStatus.OPEN]: 'Open',
  [JobStatus.ON_HOLD]: 'On Hold',
  [JobStatus.IN_REVIEW]: 'In Review',
  [JobStatus.INTERVIEWING]: 'Interviewing',
  [JobStatus.OFFER_EXTENDED]: 'Offer Extended',
  [JobStatus.OFFER_ACCEPTED]: 'Offer Accepted',
  [JobStatus.CLOSED]: 'Closed',
  [JobStatus.ARCHIVED]: 'Archived',
  [JobStatus.OFFER_DECLINED]: 'Offer Declined',
  [JobStatus.REOPENED]: 'Reopened',
  [JobStatus.CANCELLED]: 'Cancelled'
};
