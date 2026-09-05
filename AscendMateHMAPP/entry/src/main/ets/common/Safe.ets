export class Safe {
  static top(): number {
    return AppStorage.get<number>('topSafe') ?? 0;
  }

  static bottom(): number {
    return AppStorage.get<number>('bottomSafe') ?? 0;
  }
}
