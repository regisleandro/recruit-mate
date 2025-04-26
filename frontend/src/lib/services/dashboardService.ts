import { apiRequest } from '$lib/utils/api';

export interface DashboardStats {
  jobs_opened: number;
  applications: number;
  jobs_with_offers: number;
}

export interface RecentJob {
  id: string;
  title: string;
  company_name: string;
  created_at: string;
}

export interface RecentCandidate {
  id: string;
  name: string;
  created_at: string;
}

export interface RecentApplication {
  id: string;
  candidate_name: string;
  job_title: string;
  company_name: string;
  status: string;
  created_at: string;
}

export interface RecentActivity {
  new_jobs: RecentJob[];
  new_candidates: RecentCandidate[];
  new_applications: RecentApplication[];
}

export interface DashboardData {
  stats: DashboardStats;
  recent_activity: RecentActivity;
}

export async function getDashboardData(): Promise<DashboardData> {
  try {
    const response = await apiRequest<DashboardData>('/dashboard');
    return response;
  } catch (error) {
    console.error('Error fetching dashboard data:', error);
    throw error;
  }
}
