module BugCache
  CACHE_KEY = 'bugs_count'.freeze

  def update_bugs_count_cache(token)
    $redis.set(
      token,
      Bug.count_by_application_token(token)
    )
  end

  def cached_bugs_count(token)
    if $redis.get(token).nil?
      Bug.count_by_application_token(token).to_s
    else
      $redis.get(token)
    end
  end

  def bug_cache_key
    CACHE_KEY
  end
end
