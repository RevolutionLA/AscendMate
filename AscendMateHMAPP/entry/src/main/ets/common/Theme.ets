export class Theme {
  static readonly spaceXs: number = 4;
  static readonly spaceSm: number = 8;
  static readonly spaceMd: number = 12;
  static readonly spaceLg: number = 16;
  static readonly spaceXl: number = 20;
  static readonly space2xl: number = 24;
  static readonly space3xl: number = 32;
  static readonly radiusSm: number = 8;
  static readonly radiusMd: number = 12;
  static readonly radiusLg: number = 14;
  static readonly radiusXl: number = 20;
  static readonly tabBarHeight: number = 56;
  static readonly touchTarget: number = 44;
  static readonly stageColors: string[] = ['#6B8CBD', '#5FA8A0', '#7FA65A', '#C9A24B', '#A984C4', '#C86B7E'];
  static readonly brandGradient: Array<[ResourceColor, number]> = [['#C8102E', 0], ['#E03148', 1]];
  static readonly deepGradient: Array<[ResourceColor, number]> = [['#101318', 0], ['#171C24', 1]];

  static fontPx(level: string): number {
    if (level === 'S') {
      return 14;
    }
    if (level === 'L') {
      return 17;
    }
    if (level === 'XL') {
      return 19;
    }
    return 15;
  }
}
