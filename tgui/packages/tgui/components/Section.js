/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { BoxProps, computeBoxClassName, computeBoxProps } from './Box';
import { Component, InfernoNode, RefObject, createRef } from 'inferno';
import { addScrollableNode, removeScrollableNode } from '../events';
import { canRender, classes } from 'common/react';

type SectionProps = BoxProps & {
  className?: string;
  title?: InfernoNode;
  buttons?: InfernoNode;
  fill?: boolean;
  fitted?: boolean;
  scrollable?: boolean;
  /** @deprecated This property no longer works, please remove it. */
  level?: never;
  /** @deprecated Please use `scrollable` property */
  overflowY?: never;
  /** @member Allows external control of scrolling. */
  scrollableRef?: RefObject<HTMLDivElement>;
  /** @member Callback function for the `scroll` event */
  onScroll?: (this: GlobalEventHandlers, ev: Event) => any;
};

export class Section extends Component<SectionProps> {
  scrollableRef: RefObject<HTMLDivElement>;
  scrollable: boolean;

export class Section extends Component {
  constructor(props) {
    super(props);
    this.ref = createRef();
    this.scrollable = props.scrollable;
  }

  componentDidMount() {
    if (this.scrollable || this.scrollableHorizontal) {
      addScrollableNode(this.scrollableRef.current as HTMLElement);
      if (this.onScroll && this.scrollableRef.current) {
        this.scrollableRef.current.onscroll = this.onScroll;
      }
    }
  }

  componentWillUnmount() {
    if (this.scrollable || this.scrollableHorizontal) {
      removeScrollableNode(this.scrollableRef.current as HTMLElement);
    }
  }

  render() {
    const {
      className,
      title,
      level = 1,
      buttons,
      fill,
      fitted,
      scrollable,
      children,
      ...rest
    } = this.props;
    const hasTitle = canRender(title) || canRender(buttons);
    const content = fitted
      ? children
      : (
        <div
          ref={this.ref}
          className="Section__content">
          {children}
        </div>
      );
    return (
      <div
        ref={fitted ? this.ref : undefined}
        className={classes([
          'Section',
          'Section--level--' + level,
          Byond.IS_LTE_IE8 && 'Section--iefix',
          fill && 'Section--fill',
          fitted && 'Section--fitted',
          scrollable && 'Section--scrollable',
          className,
          ...computeBoxClassName(rest),
        ])}
        {...computeBoxProps(rest)}>
        {hasTitle && (
          <div className="Section__title">
            <span className="Section__titleText">{title}</span>
            <div className="Section__buttons">{buttons}</div>
          </div>
        )}
        <div className="Section__rest">
          {content}
        </div>
      </div>
    );
  }
}
