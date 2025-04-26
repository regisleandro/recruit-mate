<script lang="ts">
  import ProtectedRoute from '$lib/components/ProtectedRoute.svelte';
  import { auth } from '$lib/stores/auth';
  import { onMount } from 'svelte';
  import { getDashboardData } from '$lib/services/dashboardService';
  import type { DashboardData } from '$lib/services/dashboardService';
  import { formatDistanceToNow } from 'date-fns';
  import { enUS, ptBR } from 'date-fns/locale';
  import T from '$lib/i18n/T.svelte';
  import { currentLang } from '$lib/i18n/store';

  let dashboardData: DashboardData | null = null;
  let loading = true;
  let error = false;

  onMount(async () => {
    try {
      dashboardData = await getDashboardData();
    } catch (e) {
      console.error('Error loading dashboard data:', e);
      error = true;
    } finally {
      loading = false;
    }
  });

  function formatDate(dateString: string): string {
    try {
      // Use the appropriate locale based on the current language
      const locale = $currentLang === 'pt' ? ptBR : enUS;
      return formatDistanceToNow(new Date(dateString), {
        addSuffix: true,
        locale
      });
    } catch (e) {
      return 'Unknown date';
    }
  }
</script>

<ProtectedRoute>
  <div class="dashboard">
    <div class="welcome-card">
      <h2><T key="welcome" />, {$auth.user?.name || 'User'}!</h2>
      <p><T key="welcomeMessage" /></p>
    </div>

    {#if loading}
      <div class="loading">
        <p><T key="loadingDashboard" /></p>
      </div>
    {:else if error}
      <div class="error-message">
        <p><T key="dashboardError" /></p>
      </div>
    {:else if dashboardData}
      <div class="dashboard-content">
        <div class="stats-card">
          <h3><T key="systemStats" /></h3>
          <div class="stats-grid">
            <div class="stat-item">
              <span class="stat-value">{dashboardData.stats.jobs_opened}</span>
              <span class="stat-label"><T key="openJobs" /></span>
            </div>
            <div class="stat-item">
              <span class="stat-value">{dashboardData.stats.applications}</span>
              <span class="stat-label"><T key="applications" /></span>
            </div>
            <div class="stat-item">
              <span class="stat-value"
                >{dashboardData.stats.jobs_with_offers}</span
              >
              <span class="stat-label"><T key="offersExtended" /></span>
            </div>
          </div>
        </div>

        <div class="recent-activity">
          <h3><T key="recentActivity" /></h3>

          <div class="activity-section">
            <h4><T key="newJobs" /></h4>
            {#if dashboardData.recent_activity.new_jobs.length === 0}
              <p class="no-data"><T key="noRecentJobs" /></p>
            {:else}
              <ul class="activity-list">
                {#each dashboardData.recent_activity.new_jobs as job}
                  <li class="activity-item">
                    <span class="activity-date"
                      >{formatDate(job.created_at)}</span
                    >
                    <span class="activity-text">
                      <a href="/jobs/{job.id}">{job.title}</a>
                      <T key="at" />
                      {job.company_name}
                    </span>
                  </li>
                {/each}
              </ul>
            {/if}
          </div>

          <div class="activity-section">
            <h4><T key="newCandidates" /></h4>
            {#if dashboardData.recent_activity.new_candidates.length === 0}
              <p class="no-data"><T key="noRecentCandidates" /></p>
            {:else}
              <ul class="activity-list">
                {#each dashboardData.recent_activity.new_candidates as candidate}
                  <li class="activity-item">
                    <span class="activity-date"
                      >{formatDate(candidate.created_at)}</span
                    >
                    <span class="activity-text">
                      <a href="/candidates/{candidate.id}">{candidate.name}</a>
                      <T key="joinedPlatform" />
                    </span>
                  </li>
                {/each}
              </ul>
            {/if}
          </div>

          <div class="activity-section">
            <h4><T key="newApplications" /></h4>
            {#if dashboardData.recent_activity.new_applications.length === 0}
              <p class="no-data"><T key="noRecentApplications" /></p>
            {:else}
              <ul class="activity-list">
                {#each dashboardData.recent_activity.new_applications as application}
                  <li class="activity-item">
                    <span class="activity-date"
                      >{formatDate(application.created_at)}</span
                    >
                    <span class="activity-text">
                      <a href="/candidates/{application.id}"
                        >{application.candidate_name}</a
                      >
                      <T key="appliedFor" />
                      <a href="/jobs/{application.id}"
                        >{application.job_title}</a
                      >
                      <T key="at" />
                      {application.company_name}
                    </span>
                  </li>
                {/each}
              </ul>
            {/if}
          </div>
        </div>
      </div>
    {/if}
  </div>
</ProtectedRoute>

<style>
  .dashboard {
    max-width: 1200px;
    margin: 0 auto;
    padding: 2rem;
  }

  h1 {
    margin-bottom: 2rem;
    color: #333;
  }

  .welcome-card {
    background-color: #4a90e2;
    color: white;
    padding: 2rem;
    border-radius: 8px;
    margin-bottom: 2rem;
    box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
  }

  .welcome-card h2 {
    margin-top: 0;
    margin-bottom: 0.5rem;
  }

  .welcome-card p {
    margin-bottom: 0;
    opacity: 0.9;
  }

  .dashboard-content {
    display: grid;
    grid-template-columns: 1fr 2fr;
    gap: 2rem;
  }

  .stats-card {
    background-color: white;
    padding: 1.5rem;
    border-radius: 8px;
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
  }

  .stats-card h3 {
    margin-top: 0;
    margin-bottom: 1.5rem;
    color: #333;
  }

  .stats-grid {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 1rem;
  }

  .stat-item {
    display: flex;
    flex-direction: column;
    align-items: center;
    text-align: center;
  }

  .stat-value {
    font-size: 2rem;
    font-weight: bold;
    color: #4a90e2;
  }

  .stat-label {
    font-size: 0.9rem;
    color: #666;
  }

  .recent-activity {
    background-color: white;
    padding: 1.5rem;
    border-radius: 8px;
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
  }

  .recent-activity h3 {
    margin-top: 0;
    margin-bottom: 1.5rem;
    color: #333;
  }

  .activity-section {
    margin-bottom: 1.5rem;
  }

  .activity-section h4 {
    color: #555;
    margin-bottom: 0.5rem;
    border-bottom: 1px solid #eee;
    padding-bottom: 0.5rem;
  }

  .activity-list {
    list-style: none;
    padding: 0;
    margin: 0;
  }

  .activity-item {
    padding: 0.75rem 0;
    border-bottom: 1px solid #eee;
    display: flex;
    flex-direction: column;
  }

  .activity-item:last-child {
    border-bottom: none;
  }

  .activity-date {
    font-size: 0.8rem;
    color: #999;
    margin-bottom: 0.25rem;
  }

  .activity-text {
    color: #333;
  }

  .activity-text a {
    color: #4a90e2;
    text-decoration: none;
    font-weight: 500;
  }

  .activity-text a:hover {
    text-decoration: underline;
  }

  .no-data {
    color: #999;
    font-style: italic;
    padding: 0.5rem 0;
  }

  .loading,
  .error-message {
    background-color: white;
    padding: 2rem;
    border-radius: 8px;
    text-align: center;
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
  }

  .error-message {
    color: #e74c3c;
  }

  @media (max-width: 768px) {
    .dashboard-content {
      grid-template-columns: 1fr;
    }
  }
</style>
