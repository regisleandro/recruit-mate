<script lang="ts">
  import ProtectedRoute from '$lib/components/ProtectedRoute.svelte';
  import { auth } from '$lib/stores/auth';
</script>

<ProtectedRoute>
  <div class="dashboard">
    <h1>Dashboard</h1>

    <div class="welcome-card">
      <h2>Welcome, {$auth.user?.name || 'User'}!</h2>
      <p>You are now logged in to your account.</p>
    </div>

    <div class="dashboard-content">
      <div class="stats-card">
        <h3>Your Stats</h3>
        <div class="stats-grid">
          <div class="stat-item">
            <span class="stat-value">12</span>
            <span class="stat-label">Applications</span>
          </div>
          <div class="stat-item">
            <span class="stat-value">3</span>
            <span class="stat-label">Interviews</span>
          </div>
          <div class="stat-item">
            <span class="stat-value">2</span>
            <span class="stat-label">Offers</span>
          </div>
        </div>
      </div>

      <div class="recent-activity">
        <h3>Recent Activity</h3>
        <ul class="activity-list">
          <li class="activity-item">
            <span class="activity-date">Today</span>
            <span class="activity-text"
              >You applied to Software Engineer at TechCorp</span
            >
          </li>
          <li class="activity-item">
            <span class="activity-date">Yesterday</span>
            <span class="activity-text"
              >Interview scheduled with InnoSystems</span
            >
          </li>
          <li class="activity-item">
            <span class="activity-date">3 days ago</span>
            <span class="activity-text"
              >You received a job offer from DevLink</span
            >
          </li>
        </ul>
      </div>
    </div>
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

  .activity-list {
    list-style: none;
    padding: 0;
    margin: 0;
  }

  .activity-item {
    padding: 1rem 0;
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

  @media (max-width: 768px) {
    .dashboard-content {
      grid-template-columns: 1fr;
    }
  }
</style>
