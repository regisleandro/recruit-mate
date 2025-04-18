import { error } from '@sveltejs/kit';
import type { PageLoad } from './$types';

export const load: PageLoad = async ({ params }) => {
  if (!params.id) {
    throw error(404, 'Job not found');
  }

  return {
    jobId: params.id
  };
};
