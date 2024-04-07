interface ByondType {
  /**
   * If `true`, unhandled errors and common mistakes result in a blue screen
   * of death, which stops this window from handling incoming messages and
   * closes the active instance of tgui datum if there was one.
   *
   * It can be defined in window.initialize() in DM, or changed in runtime
   * here via this property to `true` or `false`.
   *
   * It is recommended that you keep this ON to detect hard to find bugs.
   */
  strictMode: boolean;

  /**
   * Makes a BYOND call.
   *
   * If path is empty, this will trigger a Topic call.
   * You can reference a specific object by setting the "src" parameter.
   *
   * See: https://secure.byond.com/docs/ref/skinparams.html
   */
  call(path: string, params: object): void;

  /**
   * Makes an asynchronous BYOND call. Returns a promise.
   */
  callAsync(path: string, params: object): Promise<any>;

  /**
   * Makes a Topic call.
   *
   * You can reference a specific object by setting the "src" parameter.
   */
  topic(params: object): void;

  /**
   * Runs a command or a verb.
   */
  command(command: string): void;

  /**
   * Retrieves all properties of the BYOND skin element.
   *
   * Returns a promise with a key-value object containing all properties.
   */
  winget(id: string): Promise<object>;

  /**
   * Retrieves all properties of the BYOND skin element.
   *
   * Returns a promise with a key-value object containing all properties.
   */
  winget(id: string, propName: '*'): Promise<object>;

  /**
   * Retrieves an exactly one property of the BYOND skin element,
   * as defined in `propName`.
   *
   * Returns a promise with the value of that property.
   */
  winget(id: string, propName: string): Promise<any>;

  /**
   * Retrieves multiple properties of the BYOND skin element,
   * as defined in the `propNames` array.
   *
   * Returns a promise with a key-value object containing listed properties.
   */
  winget(id: string, propNames: string[]): Promise<object>;

  /**
   * Assigns properties to BYOND skin elements.
   */
  winset(props: object): void;

  /**
   * Assigns properties to the BYOND skin element.
   */
  winset(id: string, props: object): void;

  /**
   * Sets a property on the BYOND skin element to a certain value.
   */
  winset(id: string, propName: string, propValue: any): void;

  /**
   * Parses BYOND JSON.
   *
   * Uses a special encoding to preverse Infinity and NaN.
   */
  parseJson(text: string): any;

  /**
   * Loads a stylesheet into the document.
   */
  loadCss(url: string): void;

  /**
   * Loads a script into the document.
   */
  loadJs(url: string): void;
};

/**
 * Object that provides access to Byond Skin API and is available in
 * any tgui application.
 */
const Byond: ByondType;

interface Window {
  Byond: ByondType;
  __store__: Store<unknown, AnyAction>;
  __augmentStack__: (store: Store) => StackAugmentor;
}

declare const Byond: ByondType;
