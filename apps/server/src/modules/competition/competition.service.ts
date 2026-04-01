export type CompetitionItem = {
  websiteUrl: string;
  title: string;
  applyLink: string;
  deadline: string;
};

const COMPETITIONS: CompetitionItem[] = [
  {
    websiteUrl: 'https://www.droneexpo.in/',
    title: 'Drone Expo 2026',
    applyLink: 'https://www.droneexpo.in/visitor-registration',
    deadline: '2026-04-17',
  },
  {
    websiteUrl: 'https://www.ursc.gov.in/IRoC-U2026/events.jsp#skipmaincontent',
    title: 'ISRO Robotics Challenge 2026',
    applyLink: 'https://www.ursc.gov.in/IRoC-U2026/events.jsp#skipmaincontent',
    deadline: '2026-04-02',
  },
  {
    websiteUrl: 'https://www.safmc.com.sg/about-the-competition/',
    title: 'Singapore Amazing Flying Machine Competition',
    applyLink: 'https://www.safmc.com.sg/registration/',
    deadline: '2026-02-27',
  },
  {
    websiteUrl: 'https://roboclub.technoxian.com/',
    title: 'Technoxian World Robotics Championship 10.0',
    applyLink: 'https://roboclub.technoxian.com/',
    deadline: '2026-04-07',
  },
];

export class CompetitionService {
  async getCompetitions() {
    return COMPETITIONS;
  }
}

export const competitionService = new CompetitionService();
