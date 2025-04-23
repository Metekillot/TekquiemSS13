import {
  Button,
  Flex,
  Knob,
  LabeledControls,
  NumberInput,
  Section,
} from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';
import { capitalizeFirst } from 'tgui-core/string';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  temperature: number;
  fluid_type: string;
  minTemperature: number;
  maxTemperature: number;
  fluidTypes: string[];
  contents: { ref: string; name: string }[];
  allow_breeding: BooleanLike;
};

export const Aquarium = (props) => {
  const { data } = useBackend<Data>();
  const { fishData } = data;

  return (
    <Window width={500} height={400}>
      <Window.Content>
        <Section title="Aquarium Controls">
          <LabeledControls>
            <LabeledControls.Item label="Temperature">
              <Knob
                size={1.25}
                mb={1}
                value={temperature}
                unit="K"
                minValue={minTemperature}
                maxValue={maxTemperature}
                step={1}
                stepPixelSize={1}
                onDrag={(_, value) =>
                  act('temperature', {
                    temperature: value,
                  })
                }
              />
            </LabeledControls.Item>
            <LabeledControls.Item label="Fluid">
              <Flex direction="column" mb={1}>
                {fluidTypes.map((f) => (
                  <Flex.Item key={f}>
                    <Button
                      fluid
                      content={f}
                      selected={fluid_type === f}
                      onClick={() => act('fluid', { fluid: f })}
                    />
                  </Flex.Item>
                ))}
              </Flex>
            </LabeledControls.Item>
            <LabeledControls.Item label="Reproduction Prevention System">
              <Button
                content={allow_breeding ? 'Offline' : 'Online'}
                selected={!allow_breeding}
                onClick={() => act('allow_breeding')}
              />
            </LabeledControls.Item>
          </LabeledControls>
        </Section>
        <Section title="Contents">
          {contents.map((movable) => (
            <Button
              key={movable.ref}
              content={movable.name}
              onClick={() => act('remove', { ref: movable.ref })}
            />
          ))}
        </Section>
      </Window.Content>
    </Window>
  );
};

type FishInfoProps = {
  fish: FishData;
};

const FishInfo = (props: FishInfoProps) => {
  const { act } = useBackend<Data>();
  const { fish } = props;

  return (
    <Stack vertical>
      <Stack.Item>
        <Flex>
          <Flex.Item width="40px">
            <DmIcon
              style={{ borderRadius: '1em', background: '#151326' }}
              icon={fish.fish_icon}
              icon_state={fish.fish_icon_state}
              height="40px"
              width="40px"
            />
          </Flex.Item>
          <Flex.Item grow>
            <Stack vertical>
              <Stack.Item
                ml={1}
                style={{ fontSize: '13px', fontWeight: 'bold' }}
              >
                {fish.fish_name}
              </Stack.Item>
              <Stack.Item mt={fish.fish_health > 0 ? -4 : 1}>
                {fish.fish_health > 0 ? (
                  <CalculateHappiness happiness={fish.fish_happiness} />
                ) : (
                  <Icon ml={2} name="skull-crossbones" textColor="white" />
                )}
              </Stack.Item>
            </Stack>
          </Flex.Item>
          <Flex.Item>
            <Flex>
              <Button
                fluid
                icon="arrow-up"
                color="transparent"
                onClick={() =>
                  act('remove_item', {
                    item_reference: fish.fish_ref,
                  })
                }
              />
            </Flex>
          </Flex.Item>
        </Flex>
      </Stack.Item>
      <Stack.Item grow>
        <Flex>
          <Flex.Item width="50%">
            <Button
              textAlign="center"
              mt={1}
              fluid
              color="transparent"
              icon="paw"
              style={{
                padding: '3px',
                borderRadius: '1em',
                background: '#151326',
              }}
              onClick={() =>
                act('pet_fish', {
                  fish_reference: fish.fish_ref,
                })
              }
            >
              Pet
            </Button>
          </Flex.Item>
          <Flex.Item width="50%">
            <Button.Input
              textAlign="center"
              mt={1}
              ml={1}
              fluid
              icon="keyboard"
              buttonText="Rename"
              color="transparent"
              onCommit={(value) => {
                act('rename_fish', {
                  fish_reference: fish.fish_ref,
                  chosen_name: value,
                });
              }}
              style={{
                padding: '3px',
                borderRadius: '1em',
                background: '#151326',
              }}
              value={fish.fish_name}
            />
          </Flex.Item>
        </Flex>
      </Stack.Item>
    </Stack>
  );
};

const PropTypes = (props) => {
  const { act, data } = useBackend<Data>();
  const { propData } = data;

  return (
    <Section scrollable fill title="Props">
      <Stack vertical>
        {propData.map((prop) => (
          <Stack.Item className="candystripe" key={prop.prop_ref}>
            <Button
              fluid
              color="transparent"
              onClick={() =>
                act('remove_item', {
                  item_reference: prop.prop_ref,
                })
              }
            >
              <Flex>
                <Flex.Item>
                  <DmIcon
                    icon={prop.prop_icon}
                    icon_state={prop.prop_icon_state}
                    height="40px"
                    width="40px"
                  />
                </Flex.Item>
                <Flex.Item
                  ml={1}
                  mt={1}
                  style={{ fontSize: '11px', fontWeight: 'bold' }}
                >
                  {capitalizeFirst(prop.prop_name)}
                </Flex.Item>
              </Flex>
            </Button>
          </Stack.Item>
        ))}
      </Stack>
    </Section>
  );
};

const CalculateHappiness = (props) => {
  const { data } = useBackend<Data>();
  const { heartIcon } = data;
  const { happiness } = props;

  return (
    <Box>
      {Array.from({ length: 5 }, (_, index) => (
        <DmIcon
          key={index}
          ml={index === 0 ? 0 : -6}
          icon={heartIcon}
          icon_state={happiness >= index ? 'full_heart' : 'empty_heart'}
          height="48px"
          width="48px"
        />
      ))}
    </Box>
  );
};

const Settings = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    temperature,
    minTemperature,
    maxTemperature,
    fluidTypes,
    fluidType,
    safe_mode,
    feedingInterval,
  } = data;

  return (
    <Flex fill>
      <Flex.Item grow>
        <Section fill title="Temperature">
          <Knob
            mt={3}
            size={1.5}
            mb={1}
            value={temperature}
            unit="K"
            minValue={minTemperature}
            maxValue={maxTemperature}
            step={1}
            stepPixelSize={1}
            onDrag={(_, value) =>
              act('temperature', {
                temperature: value,
              })
            }
          />
        </Section>
      </Flex.Item>
      <Flex.Item ml={1} grow>
        <Section fill title="Fluid">
          <Flex direction="column" mb={1}>
            {fluidTypes.map((f) => (
              <Flex.Item className="candystripe" key={f}>
                <Button
                  textAlign="center"
                  fluid
                  color="transparent"
                  selected={fluidType === f}
                  onClick={() => act('fluid', { fluid: f })}
                >
                  {f}
                </Button>
              </Flex.Item>
            ))}
          </Flex>
        </Section>
      </Flex.Item>
      <Flex.Item ml={1} grow>
        <Section fill title="Settings">
          <Box mt={2}>
            <LabeledList>
              <LabeledList.Item label="Safe Mode">
                <Button
                  textAlign="center"
                  width="75px"
                  tooltip="Prevent fish dying in hostile water and temperatures at the cost of features like growth and reproduction"
                  content={safe_mode ? 'Online' : 'Offline'}
                  selected={safe_mode}
                  onClick={() => act('safe_mode')}
                />
              </LabeledList.Item>
              <LabeledList.Item label="Feeding Interval">
                <NumberInput
                  width="15px"
                  value={feedingInterval}
                  minValue={1}
                  maxValue={7}
                  step={1}
                  unit="minutes"
                  onChange={(value) =>
                    act('feeding_interval', {
                      feeding_interval: value,
                    })
                  }
                />
              </LabeledList.Item>
            </LabeledList>
          </Box>
        </Section>
      </Flex.Item>
    </Flex>
  );
};
function dissectName(input: string): string {
  return input.split(' ')[0].slice(0, 18);
}
