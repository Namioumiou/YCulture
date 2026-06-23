export const generateRoomCode = (length: number = 6): string => {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  let code = '';
  for (let i = 0; i < length; i++) {
    code += chars.charAt(Math.floor(Math.random() * chars.length));
  }
  return code;
};

export const calculatePoints = (
  basePoints: number,
  timeToAnswer: number,
  timeLimit: number
): number => {
  // Award more points for faster answers
  const timeFactor = 1 - (timeToAnswer / timeLimit);
  const bonus = Math.floor(basePoints * timeFactor * 0.5);
  return basePoints + bonus;
};

export const sleep = (ms: number): Promise<void> => {
  return new Promise(resolve => setTimeout(resolve, ms));
};
