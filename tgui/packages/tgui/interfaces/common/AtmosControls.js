import {
  Button,
  LabeledList,
  NumberInput,
  Section,
} from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';
import { decodeHtmlEntities } from 'tgui-core/string';

import { useBackend } from '../../backend';
import { getGasLabel } from '../../constants';

export type VentProps = {
  refID: string;
  long_name: string;
  power: BooleanLike;
  overclock: BooleanLike;
  integrity: number;
  checks: number;
  excheck: BooleanLike;
  incheck: BooleanLike;
  direction: number;
  external: number;
  internal: number;
  extdefault: number;
  intdefault: number;
};

export type ScrubberProps = {
  refID: string;
  long_name: string;
  power: BooleanLike;
  scrubbing: BooleanLike;
  widenet: BooleanLike;
  filter_types: {
    gas_id: string;
    gas_name: string;
    enabled: BooleanLike;
  }[];
};

export const Vent = (props: VentProps) => {
  const { act } = useBackend();
  const {
    id_tag,
    long_name,
    power,
    checks,
    excheck,
    incheck,
    direction,
    external,
    internal,
    extdefault,
    intdefault,
  } = vent;
  return (
    <Section
      level={2}
      title={decodeHtmlEntities(long_name)}
      buttons={
        <>
          <Button
            icon={power ? 'power-off' : 'times'}
            selected={power}
            disabled={integrity <= 0}
            content={power ? 'On' : 'Off'}
            onClick={() =>
              act('power', {
                ref: refID,
                val: Number(!power),
              })
            }
          />
          <Button
            icon="gauge-high"
            color={overclock ? 'green' : 'yellow'}
            disabled={integrity <= 0}
            onClick={() =>
              act('overclock', {
                ref: refID,
              })
            }
            tooltip={`${overclock ? 'Disable' : 'Enable'} overclocking`}
          />
        </>
      }
    >
      <LabeledList>
        <LabeledList.Item label="Integrity">
          <p
            title={
              'Overclocking will allow the vent to overpower extreme pressure conditions. However, it will also cause the vent to become damaged over time and eventually fail. The lower the integrity, the less effective the vent will be when in normal operation.'
            }
          >
            {(integrity * 100).toFixed(2)}%
          </p>
        </LabeledList.Item>
        <LabeledList.Item label="Mode">
          <Button
            icon="sign-in-alt"
            content={direction ? 'Pressurizing' : 'Scrubbing'}
            color={!direction && 'danger'}
            onClick={() =>
              act('direction', {
                id_tag,
                val: Number(!direction),
              })
            }
          />
        </LabeledList.Item>
        <LabeledList.Item label="Pressure Regulator">
          <Button
            icon="sign-in-alt"
            content="Internal"
            selected={incheck}
            onClick={() =>
              act('incheck', {
                id_tag,
                val: checks,
              })
            }
          />
          <Button
            icon="sign-out-alt"
            content="External"
            selected={excheck}
            onClick={() =>
              act('excheck', {
                id_tag,
                val: checks,
              })
            }
          />
        </LabeledList.Item>
        {!!incheck && (
          <LabeledList.Item label="Internal Target">
            <NumberInput
              value={Math.round(internal)}
              unit="kPa"
              width="75px"
              minValue={0}
              step={10}
              maxValue={5066}
              onChange={(e, value) =>
                act('set_internal_pressure', {
                  id_tag,
                  value,
                })
              }
            />
            <Button
              icon="undo"
              disabled={intdefault}
              content="Reset"
              onClick={() =>
                act('reset_internal_pressure', {
                  id_tag,
                })
              }
            />
          </LabeledList.Item>
        )}
        {!!excheck && (
          <LabeledList.Item label="External Target">
            <NumberInput
              value={Math.round(external)}
              unit="kPa"
              width="75px"
              minValue={0}
              step={10}
              maxValue={5066}
              onChange={(e, value) =>
                act('set_external_pressure', {
                  id_tag,
                  value,
                })
              }
            />
            <Button
              icon="undo"
              disabled={extdefault}
              content="Reset"
              onClick={() =>
                act('reset_external_pressure', {
                  id_tag,
                })
              }
            />
          </LabeledList.Item>
        )}
      </LabeledList>
    </Section>
  );
};

export const Scrubber = (props: ScrubberProps) => {
  const { act } = useBackend();
  const { long_name, power, scrubbing, refID, widenet, filter_types } = props;
  return (
    <Section
      level={2}
      title={decodeHtmlEntities(long_name)}
      buttons={
        <Button
          icon={power ? 'power-off' : 'times'}
          content={power ? 'On' : 'Off'}
          selected={power}
          onClick={() =>
            act('power', {
              id_tag,
              val: Number(!power),
            })
          }
        />
      }
    >
      <LabeledList>
        <LabeledList.Item label="Mode">
          <Button
            icon={scrubbing ? 'filter' : 'sign-in-alt'}
            color={scrubbing || 'danger'}
            content={scrubbing ? 'Scrubbing' : 'Siphoning'}
            onClick={() =>
              act('scrubbing', {
                id_tag,
                val: Number(!scrubbing),
              })
            }
          />
          <Button
            icon={widenet ? 'expand' : 'compress'}
            selected={widenet}
            content={widenet ? 'Expanded range' : 'Normal range'}
            onClick={() =>
              act('widenet', {
                id_tag,
                val: Number(!widenet),
              })
            }
          />
        </LabeledList.Item>
        <LabeledList.Item label="Filters">
          {(scrubbing &&
            filter_types.map((filter) => (
              <Button
                key={filter.gas_id}
                icon={filter.enabled ? 'check-square-o' : 'square-o'}
                tooltip={filter.gas_name}
                selected={filter.enabled}
                onClick={() =>
                  act('toggle_filter', {
                    id_tag,
                    val: filter.gas_id,
                  })
                }
              >
                {getGasLabel(filter.gas_id, filter.gas_name)}
              </Button>
            ))) ||
            'N/A'}
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};
