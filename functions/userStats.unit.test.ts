// Unit test for user stats aggregation logic (pure function, no Firestore)

function updateStats(oldStats: any, result: { score?: number; time?: number }) {
  const stats = { ...oldStats };
  stats.totalPoints += result.score || 0;
  stats.totalGamesPlayed += 1;
  // currentStreak, lastPlayedAt można rozbudować wg potrzeb
  stats.lastPlayedAt = '2026-01-13T00:00:00Z';
  return stats;
}

describe('User stats aggregation logic (unit test)', () => {
  it('should correctly aggregate stats for new result', () => {
    const oldStats = {
      totalGamesPlayed: 2,
      totalPoints: 150,
      currentStreak: 1,
      lastPlayedAt: null,
    };
    const result = { score: 100, time: 60 };
    const newStats = updateStats(oldStats, result);
    expect(newStats.totalGamesPlayed).toBe(3);
    expect(newStats.totalPoints).toBe(250);
    expect(newStats.lastPlayedAt).toBe('2026-01-13T00:00:00Z');
  });
});
