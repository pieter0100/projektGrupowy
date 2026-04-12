// Unit test for user stats aggregation logic (pure function, no Firestore)


function updateStats(oldStats: any, result: { score?: number; time?: number }, nowISO: string) {
  const stats = { ...oldStats };
  stats.totalPoints += result.score || 0;
  stats.totalGamesPlayed += 1;

  //  Streak logic
  let streak = 1;
  if (stats.lastPlayedAt) {
    const now = new Date(nowISO);
    const nowDay = new Date(now.getFullYear(), now.getMonth(), now.getDate());
    const last = new Date(stats.lastPlayedAt);
    const lastDay = new Date(last.getFullYear(), last.getMonth(), last.getDate());
    const diffDays = Math.floor((nowDay.getTime() - lastDay.getTime()) / (1000 * 60 * 60 * 24));
    if (diffDays === 0) {
      streak = stats.currentStreak;
    } else if (diffDays === 1) {
      streak = stats.currentStreak + 1;
    } else {
      streak = 1;
    }
  }
  stats.currentStreak = streak;
  stats.lastPlayedAt = nowISO;
  return stats;
}

describe('User stats aggregation logic (unit test)', () => {
  it('should correctly aggregate stats for first result (no streak)', () => {
    const oldStats = {
      totalGamesPlayed: 0,
      totalPoints: 0,
      currentStreak: 0,
      lastPlayedAt: null,
    };
    const result = { score: 100, time: 60 };
    const now = '2026-01-13T00:00:00Z';
    const newStats = updateStats(oldStats, result, now);
    expect(newStats.totalGamesPlayed).toBe(1);
    expect(newStats.totalPoints).toBe(100);
    expect(newStats.currentStreak).toBe(1);
    expect(newStats.lastPlayedAt).toBe(now);
  });

  it('should increment streak if played on consecutive days', () => {
    const oldStats = {
      totalGamesPlayed: 1,
      totalPoints: 100,
      currentStreak: 2,
      lastPlayedAt: '2026-01-12T10:00:00Z',
    };
    const result = { score: 50, time: 30 };
    const now = '2026-01-13T12:00:00Z';
    const newStats = updateStats(oldStats, result, now);
    expect(newStats.currentStreak).toBe(3);
    expect(newStats.lastPlayedAt).toBe(now);
  });

  it('should not increment streak if played twice the same day', () => {
    const oldStats = {
      totalGamesPlayed: 2,
      totalPoints: 150,
      currentStreak: 3,
      lastPlayedAt: '2026-01-13T08:00:00Z',
    };
    const result = { score: 20, time: 10 };
    const now = '2026-01-13T20:00:00Z';
    const newStats = updateStats(oldStats, result, now);
    expect(newStats.currentStreak).toBe(3);
    expect(newStats.lastPlayedAt).toBe(now);
  });

  it('should reset streak if played after a break', () => {
    const oldStats = {
      totalGamesPlayed: 3,
      totalPoints: 170,
      currentStreak: 4,
      lastPlayedAt: '2026-01-10T10:00:00Z',
    };
    const result = { score: 30, time: 15 };
    const now = '2026-01-13T09:00:00Z';
    const newStats = updateStats(oldStats, result, now);
    expect(newStats.currentStreak).toBe(1);
    expect(newStats.lastPlayedAt).toBe(now);
  });
});
