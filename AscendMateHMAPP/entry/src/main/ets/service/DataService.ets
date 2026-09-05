import { relationalStore, preferences } from '@kit.ArkData';
import { common, ConfigurationConstant } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { FavoriteEntry, HistoryEntry } from '../model/Models';

export class DataService {
  private static readonly instance: DataService = new DataService();
  private store: relationalStore.RdbStore | undefined = undefined;
  private prefs: preferences.Preferences | undefined = undefined;
  private appContext: common.ApplicationContext | undefined = undefined;
  private doneStages: Set<string> = new Set<string>();
  private readDocIds: Set<string> = new Set<string>();
  private favIds: Set<string> = new Set<string>();

  private constructor() {
  }

  static getInstance(): DataService {
    return DataService.instance;
  }

  async init(context: common.UIAbilityContext): Promise<void> {
    if (this.store !== undefined) {
      return;
    }
    this.appContext = context.getApplicationContext();
    const config: relationalStore.StoreConfig = {
      name: 'ascendmate.db',
      securityLevel: relationalStore.SecurityLevel.S1
    };
    this.store = await relationalStore.getRdbStore(context, config);
    await this.store.executeSql('CREATE TABLE IF NOT EXISTS favorites (doc_id TEXT PRIMARY KEY, ' +
      'title TEXT NOT NULL, cat_id TEXT NOT NULL, cat_title TEXT NOT NULL, added_at INTEGER NOT NULL)');
    await this.store.executeSql('CREATE TABLE IF NOT EXISTS history (doc_id TEXT PRIMARY KEY, ' +
      'title TEXT NOT NULL, cat_id TEXT NOT NULL, cat_title TEXT NOT NULL, read_at INTEGER NOT NULL, progress REAL NOT NULL)');
    await this.store.executeSql('CREATE TABLE IF NOT EXISTS learning (stage TEXT PRIMARY KEY, ' +
      'done INTEGER NOT NULL, updated_at INTEGER NOT NULL)');
    await this.store.executeSql('CREATE TABLE IF NOT EXISTS search_history (kw TEXT PRIMARY KEY, at INTEGER NOT NULL)');
    this.prefs = preferences.getPreferencesSync(context, { name: 'settings' });
    await this.loadState();
  }

  private async loadState(): Promise<void> {
    const done: string[] = await this.queryDoneStages();
    this.doneStages = new Set<string>(done);
    const readIds: string[] = await this.queryReadDocIds();
    this.readDocIds = new Set<string>(readIds);
    const favIds: string[] = await this.queryFavoriteIds();
    this.favIds = new Set<string>(favIds);
    AppStorage.setOrCreate('guideDone', this.getGuideDone());
    AppStorage.setOrCreate('fontLevel', this.getFontLevel());
    AppStorage.setOrCreate('themeMode', this.getThemeMode());
    AppStorage.setOrCreate('favRev', 0);
    AppStorage.setOrCreate('histRev', 0);
    AppStorage.setOrCreate('learnRev', 0);
    this.applyTheme(this.getThemeMode());
  }

  // ---------- settings ----------

  getGuideDone(): boolean {
    if (this.prefs === undefined) {
      return false;
    }
    return this.prefs.getSync('guideDone', false) as boolean;
  }

  setGuideDone(done: boolean): void {
    if (this.prefs !== undefined) {
      this.prefs.putSync('guideDone', done);
      this.prefs.flush();
    }
    AppStorage.setOrCreate('guideDone', done);
  }

  getFontLevel(): string {
    if (this.prefs === undefined) {
      return 'M';
    }
    return this.prefs.getSync('fontLevel', 'M') as string;
  }

  setFontLevel(level: string): void {
    if (this.prefs !== undefined) {
      this.prefs.putSync('fontLevel', level);
      this.prefs.flush();
    }
    AppStorage.setOrCreate('fontLevel', level);
  }

  getThemeMode(): number {
    if (this.prefs === undefined) {
      return 0;
    }
    return this.prefs.getSync('themeMode', 0) as number;
  }

  addReadSeconds(seconds: number): void {
    if (this.prefs === undefined || seconds <= 0) {
      return;
    }
    const cur: number = this.prefs.getSync('readSeconds', 0) as number;
    this.prefs.putSync('readSeconds', cur + seconds);
    this.prefs.flush();
  }

  getTotalReadSeconds(): number {
    if (this.prefs === undefined) {
      return 0;
    }
    return this.prefs.getSync('readSeconds', 0) as number;
  }

  setThemeMode(mode: number): void {
    if (this.prefs !== undefined) {
      this.prefs.putSync('themeMode', mode);
      this.prefs.flush();
    }
    AppStorage.setOrCreate('themeMode', mode);
    this.applyTheme(mode);
  }

  private applyTheme(mode: number): void {
    if (this.appContext === undefined) {
      return;
    }
    if (mode === 1) {
      this.appContext.setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT);
    } else if (mode === 2) {
      this.appContext.setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_DARK);
    } else {
      this.appContext.setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    }
  }

  // ---------- favorites ----------

  isFavorite(docId: string): boolean {
    return this.favIds.has(docId);
  }

  async toggleFavorite(docId: string, title: string, catId: string, catTitle: string): Promise<boolean> {
    if (this.store === undefined) {
      return false;
    }
    const now: number = Date.now();
    try {
      if (this.favIds.has(docId)) {
        const pred = new relationalStore.RdbPredicates('favorites');
        pred.equalTo('doc_id', docId);
        await this.store.delete(pred);
        this.favIds.delete(docId);
        this.bump('favRev');
        return false;
      }
      const bucket: relationalStore.ValuesBucket = {
        'doc_id': docId,
        'title': title,
        'cat_id': catId,
        'cat_title': catTitle,
        'added_at': now
      };
      await this.store.insert('favorites', bucket);
      this.favIds.add(docId);
      this.bump('favRev');
      return true;
    } catch (err) {
      console.error(`toggleFavorite failed: ${(err as BusinessError).code}`);
      return this.favIds.has(docId);
    }
  }

  async removeFavorite(docId: string): Promise<void> {
    if (this.store === undefined) {
      return;
    }
    const pred = new relationalStore.RdbPredicates('favorites');
    pred.equalTo('doc_id', docId);
    await this.store.delete(pred);
    this.favIds.delete(docId);
    this.bump('favRev');
  }

  async getFavorites(): Promise<FavoriteEntry[]> {
    if (this.store === undefined) {
      return [];
    }
    const pred = new relationalStore.RdbPredicates('favorites');
    pred.orderByDesc('added_at');
    const rs = await this.store.query(pred, ['doc_id', 'title', 'cat_id', 'cat_title', 'added_at']);
    const out: FavoriteEntry[] = [];
    while (rs.goToNextRow()) {
      const e = new FavoriteEntry();
      e.docId = rs.getString(rs.getColumnIndex('doc_id'));
      e.title = rs.getString(rs.getColumnIndex('title'));
      e.catId = rs.getString(rs.getColumnIndex('cat_id'));
      e.catTitle = rs.getString(rs.getColumnIndex('cat_title'));
      e.addedAt = rs.getLong(rs.getColumnIndex('added_at'));
      out.push(e);
    }
    rs.close();
    return out;
  }

  private async queryFavoriteIds(): Promise<string[]> {
    if (this.store === undefined) {
      return [];
    }
    const pred = new relationalStore.RdbPredicates('favorites');
    const rs = await this.store.query(pred, ['doc_id']);
    const out: string[] = [];
    while (rs.goToNextRow()) {
      out.push(rs.getString(rs.getColumnIndex('doc_id')));
    }
    rs.close();
    return out;
  }

  favoriteCount(): number {
    return this.favIds.size;
  }

  // ---------- history ----------

  isRead(docId: string): boolean {
    return this.readDocIds.has(docId);
  }

  readCount(): number {
    return this.readDocIds.size;
  }

  async recordOpen(docId: string, title: string, catId: string, catTitle: string): Promise<void> {
    if (this.store === undefined) {
      return;
    }
    try {
      const updBucket: relationalStore.ValuesBucket = {
        'read_at': Date.now()
      };
      const pred = new relationalStore.RdbPredicates('history');
      pred.equalTo('doc_id', docId);
      const rows: number = await this.store.update(updBucket, pred);
      if (rows === 0) {
        const bucket: relationalStore.ValuesBucket = {
          'doc_id': docId,
          'title': title,
          'cat_id': catId,
          'cat_title': catTitle,
          'read_at': Date.now(),
          'progress': 0
        };
        await this.store.insert('history', bucket);
      }
      this.readDocIds.add(docId);
      this.bump('histRev');
    } catch (err) {
      console.error(`recordOpen failed: ${(err as BusinessError).code}`);
    }
  }

  async saveProgress(docId: string, progress: number): Promise<void> {
    if (this.store === undefined) {
      return;
    }
    try {
      const bucket: relationalStore.ValuesBucket = {
        'read_at': Date.now(),
        'progress': progress
      };
      const pred = new relationalStore.RdbPredicates('history');
      pred.equalTo('doc_id', docId);
      await this.store.update(bucket, pred);
    } catch (err) {
      console.error(`saveProgress failed: ${(err as BusinessError).code}`);
    }
  }

  async getProgress(docId: string): Promise<number> {
    if (this.store === undefined) {
      return 0;
    }
    const pred = new relationalStore.RdbPredicates('history');
    pred.equalTo('doc_id', docId);
    const rs = await this.store.query(pred, ['progress']);
    let out: number = 0;
    if (rs.goToNextRow()) {
      out = rs.getDouble(rs.getColumnIndex('progress'));
    }
    rs.close();
    return out;
  }

  async getHistory(limit: number): Promise<HistoryEntry[]> {
    if (this.store === undefined) {
      return [];
    }
    const pred = new relationalStore.RdbPredicates('history');
    pred.orderByDesc('read_at');
    pred.limitAs(limit);
    const rs = await this.store.query(pred, ['doc_id', 'title', 'cat_id', 'cat_title', 'read_at', 'progress']);
    const out: HistoryEntry[] = [];
    while (rs.goToNextRow()) {
      const e = new HistoryEntry();
      e.docId = rs.getString(rs.getColumnIndex('doc_id'));
      e.title = rs.getString(rs.getColumnIndex('title'));
      e.catId = rs.getString(rs.getColumnIndex('cat_id'));
      e.catTitle = rs.getString(rs.getColumnIndex('cat_title'));
      e.readAt = rs.getLong(rs.getColumnIndex('read_at'));
      e.progress = rs.getDouble(rs.getColumnIndex('progress'));
      out.push(e);
    }
    rs.close();
    return out;
  }

  async clearHistory(): Promise<void> {
    if (this.store === undefined) {
      return;
    }
    await this.store.delete(new relationalStore.RdbPredicates('history'));
    this.readDocIds.clear();
    this.bump('histRev');
  }

  private async queryReadDocIds(): Promise<string[]> {
    if (this.store === undefined) {
      return [];
    }
    const pred = new relationalStore.RdbPredicates('history');
    const rs = await this.store.query(pred, ['doc_id']);
    const out: string[] = [];
    while (rs.goToNextRow()) {
      out.push(rs.getString(rs.getColumnIndex('doc_id')));
    }
    rs.close();
    return out;
  }

  // ---------- learning ----------

  isStageDone(docId: string): boolean {
    return this.doneStages.has(docId);
  }

  doneStageCount(): number {
    return this.doneStages.size;
  }

  async markStageDone(docId: string): Promise<void> {
    if (this.store === undefined || this.doneStages.has(docId)) {
      return;
    }
    try {
      const bucket: relationalStore.ValuesBucket = {
        'stage': docId,
        'done': 1,
        'updated_at': Date.now()
      };
      await this.store.insert('learning', bucket);
      this.doneStages.add(docId);
      this.bump('learnRev');
    } catch (err) {
      console.error(`markStageDone failed: ${(err as BusinessError).code}`);
    }
  }

  private async queryDoneStages(): Promise<string[]> {
    if (this.store === undefined) {
      return [];
    }
    const pred = new relationalStore.RdbPredicates('learning');
    const rs = await this.store.query(pred, ['stage']);
    const out: string[] = [];
    while (rs.goToNextRow()) {
      out.push(rs.getString(rs.getColumnIndex('stage')));
    }
    rs.close();
    return out;
  }

  // ---------- search history ----------

  async addSearchHistory(kw: string): Promise<void> {
    if (this.store === undefined || kw.trim() === '') {
      return;
    }
    try {
      const pred = new relationalStore.RdbPredicates('search_history');
      pred.equalTo('kw', kw);
      await this.store.delete(pred);
      const bucket: relationalStore.ValuesBucket = {
        'kw': kw,
        'at': Date.now()
      };
      await this.store.insert('search_history', bucket);
    } catch (err) {
      console.error(`addSearchHistory failed: ${(err as BusinessError).code}`);
    }
  }

  async getSearchHistory(): Promise<string[]> {
    if (this.store === undefined) {
      return [];
    }
    const pred = new relationalStore.RdbPredicates('search_history');
    pred.orderByDesc('at');
    pred.limitAs(12);
    const rs = await this.store.query(pred, ['kw']);
    const out: string[] = [];
    while (rs.goToNextRow()) {
      out.push(rs.getString(rs.getColumnIndex('kw')));
    }
    rs.close();
    return out;
  }

  async clearSearchHistory(): Promise<void> {
    if (this.store === undefined) {
      return;
    }
    await this.store.delete(new relationalStore.RdbPredicates('search_history'));
  }

  private bump(key: string): void {
    const cur: number = AppStorage.get<number>(key) ?? 0;
    AppStorage.setOrCreate(key, cur + 1);
  }
}
