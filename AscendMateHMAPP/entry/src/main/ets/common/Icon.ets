import { display } from '@kit.ArkUI';

export enum IconName {
  Home = 'home',
  Book = 'book',
  Search = 'search',
  User = 'user',
  Back = 'back',
  ChevronRight = 'chevron',
  Close = 'close',
  Star = 'star',
  Heart = 'heart',
  Toc = 'toc',
  Share = 'share',
  Copy = 'copy',
  Check = 'check',
  Clock = 'clock',
  Trash = 'trash',
  Doc = 'doc',
  Flame = 'flame',
  Graduation = 'graduation',
  Blocks = 'blocks',
  LinkBox = 'linkbox',
  Question = 'question',
  Chip = 'chip',
  Sliders = 'sliders',
  Info = 'info',
  Compass = 'compass',
  Layers = 'layers',
  Rocket = 'rocket',
  Pulse = 'pulse',
  Chart = 'chart',
  Server = 'server',
  ToolBox = 'toolbox',
  Sun = 'sun',
  Moon = 'moon',
  Play = 'play',
  Sparkle = 'sparkle',
  Alert = 'alert'
}

const ICON_DATA: Record<string, string> = {
  'home': 'F|M12 3 L2.5 10.6 L5.2 10.6 L5.2 20.6 L10 20.6 L10 15 L14 15 L14 20.6 L18.8 20.6 L18.8 10.6 L21.5 10.6 Z',
  'book': 'F|M11.4 6 C9.5 4.6 6.9 4 3.4 4.1 L3.4 19.4 C6.9 19.3 9.5 19.9 11.4 21.3 Z M12.6 6 C14.5 4.6 17.1 4 20.6 4.1 L20.6 19.4 C17.1 19.3 14.5 19.9 12.6 21.3 Z',
  'search': 'S|M3.8 10 A6.4 6.4 0 1 0 16.6 10 A6.4 6.4 0 1 0 3.8 10 M14.6 14.6 L20.4 20.4',
  'user': 'F|M12 3.4 A3.6 3.6 0 1 0 12 10.6 A3.6 3.6 0 1 0 12 3.4 Z M4.2 20.8 C4.2 16.2 7.6 13.6 12 13.6 C16.4 13.6 19.8 16.2 19.8 20.8 Z',
  'back': 'S|M14.6 4.6 L6.6 12 L14.6 19.4',
  'chevron': 'S|M9.4 4.6 L17.4 12 L9.4 19.4',
  'close': 'S|M5.6 5.6 L18.4 18.4 M18.4 5.6 L5.6 18.4',
  'star': 'F|M12 2.6 L14.9 8.7 L21.6 9.6 L16.7 14.2 L18 20.8 L12 17.6 L6 20.8 L7.3 14.2 L2.4 9.6 L9.1 8.7 Z',
  'heart': 'F|M12 20.8 L10.6 19.4 C5.6 15 2.4 12 2.4 8.4 C2.4 5.4 4.7 3.1 7.6 3.1 C9.3 3.1 10.9 3.9 12 5.3 C13.1 3.9 14.7 3.1 16.4 3.1 C19.3 3.1 21.6 5.4 21.6 8.4 C21.6 12 18.4 15 13.4 19.4 Z',
  'toc': 'S|M4 6.2 L20 6.2 M4 12 L20 12 M4 17.8 L13.5 17.8',
  'share': 'S|M12 14.4 L12 3.2 M8.2 6.8 L12 3 L15.8 6.8 M5.4 11 L5.4 20.6 L18.6 20.6 L18.6 11',
  'copy': 'S|M10.8 9 L17.3 9 A2 2 0 0 1 19.3 11 L19.3 17.3 A2 2 0 0 1 17.3 19.3 L11 19.3 A2 2 0 0 1 9 17.3 L9 11 A2 2 0 0 1 10.8 9 Z M15.3 6.6 L15.3 4.6 A1.6 1.6 0 0 0 13.7 3 L4.6 3 A1.6 1.6 0 0 0 3 4.6 L3 13.7 A1.6 1.6 0 0 0 4.6 15.3 L6.6 15.3',
  'check': 'S|M4.4 12.6 L9.6 17.8 L19.6 6.6',
  'clock': 'S|M3.6 12 A8.4 8.4 0 1 0 20.4 12 A8.4 8.4 0 1 0 3.6 12 M12 7.4 L12 12.2 L15.6 14.4',
  'trash': 'S|M4.6 7 L19.4 7 M9.6 7 L9.6 4.6 L14.4 4.6 L14.4 7 M6.6 7 L7.6 20.4 L16.4 20.4 L17.4 7 M10.3 10.6 L10.3 16.8 M13.7 10.6 L13.7 16.8',
  'doc': 'S|M6 3.2 L13.6 3.2 L18.8 8.4 L18.8 20.8 L6 20.8 Z M13.6 3.2 L13.6 8.4 L18.8 8.4',
  'flame': 'F|M12 21.9 C7.3 21.9 3.9 18.5 3.9 14.4 C3.9 10.7 6.7 8.6 8.1 6 C8.9 7.9 10.1 8.8 11.2 9.6 C11.5 7 12.4 4.6 14.4 2.5 C15.1 5.8 17.1 7.6 18.5 9.9 C19.9 12.3 20.1 13.8 20.1 14.4 C20.1 18.5 16.7 21.9 12 21.9 Z',
  'graduation': 'F|M12 3.6 L22 8.7 L12 13.8 L2 8.7 Z M6.4 11.3 L6.4 15.9 C6.4 17.9 9 19.5 12 19.5 C15 19.5 17.6 17.9 17.6 15.9 L17.6 11.3 L12 14.1 Z',
  'blocks': 'F|M3.4 3.4 L10.6 3.4 A1.6 1.6 0 0 1 12.2 5 L12.2 10.6 A1.6 1.6 0 0 1 10.6 12.2 L5 12.2 A1.6 1.6 0 0 1 3.4 10.6 Z M13.4 3.4 L19 3.4 A1.6 1.6 0 0 1 20.6 5 L20.6 10.6 A1.6 1.6 0 0 1 19 12.2 L13.4 12.2 Z M3.4 13.4 L10.6 13.4 A1.6 1.6 0 0 1 12.2 15 L12.2 19 A1.6 1.6 0 0 1 10.6 20.6 L5 20.6 A1.6 1.6 0 0 1 3.4 19 Z M13.4 13.4 L19 13.4 A1.6 1.6 0 0 1 20.6 15 L20.6 19 A1.6 1.6 0 0 1 19 20.6 L13.4 20.6 Z',
  'linkbox': 'S|M12 2.8 L20.4 7.5 L20.4 16.5 L12 21.2 L3.6 16.5 L3.6 7.5 Z M3.6 7.5 L12 12.2 L20.4 7.5 M12 12.2 L12 21.2',
  'question': 'S|M3.6 12 A8.4 8.4 0 1 0 20.4 12 A8.4 8.4 0 1 0 3.6 12 M9.6 9.2 A2.5 2.5 0 1 1 12.4 11.9 L12.4 13.6 M12.3 16.8 L12.3 16.81',
  'chip': 'S|M6.8 6.8 L17.2 6.8 A1.4 1.4 0 0 1 18.6 8.2 L18.6 15.8 A1.4 1.4 0 0 1 17.2 17.2 L6.8 17.2 A1.4 1.4 0 0 1 5.4 15.8 L5.4 8.2 A1.4 1.4 0 0 1 6.8 6.8 Z M9.4 9.4 L14.6 9.4 L14.6 14.6 L9.4 14.6 Z M9.2 2.6 L9.2 5.2 M14.8 2.6 L14.8 5.2 M9.2 18.8 L9.2 21.4 M14.8 18.8 L14.8 21.4 M2.6 9.2 L5.2 9.2 M2.6 14.8 L5.2 14.8 M18.8 9.2 L21.4 9.2 M18.8 14.8 L21.4 14.8',
  'sliders': 'S|M4 7.4 L13.9 7.4 M18.7 7.4 L20 7.4 M4 16.6 L9.5 16.6 M14.3 16.6 L20 16.6 M16.3 5.5 A1.9 1.9 0 1 0 16.3 9.3 A1.9 1.9 0 1 0 16.3 5.5 M11.9 14.7 A1.9 1.9 0 1 0 11.9 18.5 A1.9 1.9 0 1 0 11.9 14.7',
  'info': 'S|M3.6 12 A8.4 8.4 0 1 0 20.4 12 A8.4 8.4 0 1 0 3.6 12 M12 11.2 L12 16.4 M12 7.4 L12 7.41',
  'compass': 'S|M3.6 12 A8.4 8.4 0 1 0 20.4 12 A8.4 8.4 0 1 0 3.6 12 M15.9 8.1 L13.4 13.4 L8.1 15.9 L10.6 10.6 Z',
  'layers': 'F|M12 2.8 L21 8 L12 13.2 L3 8 Z M4.4 11.9 L12 15.9 L19.6 11.9 L19.6 14.2 L12 18.2 L4.4 14.2 Z M4.4 16.7 L12 20.7 L19.6 16.7 L19.6 19 L12 23 L4.4 19 Z',
  'rocket': 'F|M12 2.4 C15 4.4 16.9 8 16.9 12.1 L16.9 15.4 L19.6 18.6 L15 18 L13.3 19.8 L12 21.6 L10.7 19.8 L9 18 L4.4 18.6 L7.1 15.4 L7.1 12.1 C7.1 8 9 4.4 12 2.4 Z M12 6.8 A2.2 2.2 0 1 1 12 11.2 A2.2 2.2 0 1 1 12 6.8 Z',
  'pulse': 'S|M2.6 12 L6.8 12 L9.4 6 L13.6 18 L16.2 12 L21.4 12',
  'chart': 'F|M4 12.4 L8 12.4 L8 20 L4 20 Z M10 7 L14 7 L14 20 L10 20 Z M16 3 L20 3 L20 20 L16 20 Z',
  'server': 'S|M3.6 3.6 L20.4 3.6 A1.2 1.2 0 0 1 21.6 4.8 L21.6 9.2 A1.2 1.2 0 0 1 20.4 10.4 L3.6 10.4 A1.2 1.2 0 0 1 2.4 9.2 L2.4 4.8 A1.2 1.2 0 0 1 3.6 3.6 Z M3.6 13.6 L20.4 13.6 A1.2 1.2 0 0 1 21.6 14.8 L21.6 19.2 A1.2 1.2 0 0 1 20.4 20.4 L3.6 20.4 A1.2 1.2 0 0 1 2.4 19.2 L2.4 14.8 A1.2 1.2 0 0 1 3.6 13.6 Z M6 6.9 L6 7 M6 16.9 L6 17 M10.6 7 L17.6 7 M10.6 17 L17.6 17',
  'toolbox': 'S|M3.6 9 L20.4 9 A1.2 1.2 0 0 1 21.6 10.2 L21.6 18.6 A1.2 1.2 0 0 1 20.4 19.8 L3.6 19.8 A1.2 1.2 0 0 1 2.4 18.6 L2.4 10.2 A1.2 1.2 0 0 1 3.6 9 Z M9 9 L9 6.8 A1.4 1.4 0 0 1 10.4 5.4 L13.6 5.4 A1.4 1.4 0 0 1 15 6.8 L15 9 M11 13.4 L13 13.4 L13 15.4 L11 15.4 Z',
  'sun': 'S|M7.6 12 A4.4 4.4 0 1 0 16.4 12 A4.4 4.4 0 1 0 7.6 12 M12 2.6 L12 4.9 M12 19.1 L12 21.4 M2.6 12 L4.9 12 M19.1 12 L21.4 12 M5.4 5.4 L7 7 M17 17 L18.6 18.6 M18.6 5.4 L17 7 M7 17 L5.4 18.6',
  'moon': 'F|M20.2 14.6 A8.6 8.6 0 1 1 9.4 3.8 A7.2 7.2 0 0 0 20.2 14.6 Z',
  'play': 'F|M8 5 L19.2 12 L8 19 Z',
  'sparkle': 'F|M12 2.4 L13.8 8.2 L19.6 10 L13.8 11.8 L12 17.6 L10.2 11.8 L4.4 10 L10.2 8.2 Z M18.3 15.2 L19.1 17.2 L21.1 18 L19.1 18.8 L18.3 20.8 L17.5 18.8 L15.5 18 L17.5 17.2 Z',
  'alert': 'S|M12 3.4 L21.6 20.6 L2.4 20.6 Z M12 9.4 L12 14.6 M12 17.2 L12 17.21'
};

export class IconLib {
  static commands(name: IconName): string {
    const raw: string | undefined = ICON_DATA[name];
    if (raw === undefined) {
      return '';
    }
    return raw.slice(2);
  }

  static isFilled(name: IconName): boolean {
    const raw: string | undefined = ICON_DATA[name];
    if (raw === undefined) {
      return false;
    }
    return raw.startsWith('F|');
  }
}

@Component
export struct Icon {
  @Prop name: IconName = IconName.Home;
  @Prop iconSize: number = 24;
  @Prop color: ResourceColor = '#8B95A5';

  private density(): number {
    return display.getDefaultDisplaySync().densityPixels;
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Path({
        width: 24 / this.density(),
        height: 24 / this.density(),
        commands: IconLib.commands(this.name)
      })
        .scale({
          x: this.iconSize * this.density() / 24,
          y: this.iconSize * this.density() / 24
        })
        .fill(IconLib.isFilled(this.name) ? this.color : Color.Transparent)
        .stroke(IconLib.isFilled(this.name) ? Color.Transparent : this.color)
        .strokeWidth(2 / this.density())
        .strokeLineCap(LineCapStyle.Round)
        .strokeLineJoin(LineJoinStyle.Round)
    }
    .width(this.iconSize)
    .height(this.iconSize)
  }
}
