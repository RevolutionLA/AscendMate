export class Nav {
  static stack: NavPathStack = new NavPathStack();

  static pushDoc(docId: string): void {
    Nav.stack.pushPathByName('docDetail', docId);
  }

  static pushCategory(catId: string): void {
    Nav.stack.pushPathByName('docList', catId);
  }

  static pushPage(name: string): void {
    Nav.stack.pushPathByName(name, '');
  }

  static pop(): void {
    Nav.stack.pop();
  }

  static goTab(index: number): void {
    AppStorage.setOrCreate('tabIndex', index);
  }
}
