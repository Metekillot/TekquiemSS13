import { useState } from 'react';
import {
  BlockQuote,
  Box,
  Button,
  Icon,
  Image,
  Input,
  LabeledList,
  Section,
  Stack,
  Table,
  Tabs,
} from 'tgui-core/components';
import { formatSiUnit } from 'tgui-core/format';
import { createSearch, toTitleCase } from 'tgui-core/string';

import { useBackend, useSharedState } from '../backend';
import { Window } from '../layouts';

export const OreRedemptionMachine = (props) => {
  const { act, data } = useBackend();
  const { disconnected, unclaimedPoints, materials, user } = data;
  const [tab, setTab] = useSharedState('tab', 1);
  const [searchItem, setSearchItem] = useState('');
  const [compact, setCompact] = useState(false);
  const search = createSearch(searchItem, (materials) => materials.name);
  const material_filtered =
    searchItem.length > 0
      ? data.materials.filter(search)
      : materials.filter((material) => material && material.category === tab);

  return (
    <Window title="Ore Redemption Machine" width={440} height={550}>
      <Window.Content scrollable>
        <Section>
          <BlockQuote mb={1}>
            This machine only accepts ore.
            <br />
            Gibtonite and Slag are not accepted.
          </BlockQuote>
          <Box>
            <Box inline color="label" mr={1}>
              Unclaimed points:
            </Box>
            {unclaimedPoints}
            <Button
              ml={2}
              content="Claim"
              disabled={unclaimedPoints === 0}
              onClick={() => act('Claim')}
            />
          </Box>
        </Section>
        <Section>
          {(hasDisk && (
            <>
              <Box mb={1}>
                <Button
                  icon="eject"
                  content="Eject design disk"
                  onClick={() => act('diskEject')}
                />
              </Box>
            </Stack.Item>
          </Section>
          <Section>
            <Stack.Item>
              <BlockQuote>
                This machine only accepts ore. Gibtonite and Slag are not
                accepted.
              </BlockQuote>
            </Stack.Item>
          </Section>
          <Tabs>
            <Tabs.Tab
              icon="list"
              lineHeight="23px"
              selected={tab === 'material'}
              onClick={() => {
                setTab('material');

                if (searchItem.length > 0) {
                  setSearchItem('');
                }
              }}
            >
              Materials
            </Tabs.Tab>
            <Tabs.Tab
              icon="list"
              lineHeight="23px"
              selected={tab === 'alloy'}
              onClick={() => {
                setTab('alloy');

                if (searchItem.length > 0) {
                  setSearchItem('');
                }
              }}
            >
              Alloys
            </Tabs.Tab>
            <Input
              autofocus
              position="relative"
              left="25%"
              bottom="5%"
              height="20px"
              width="150px"
              placeholder="Search Material..."
              value={searchItem}
              onInput={(e, value) => {
                setSearchItem(value);

                if (value.length > 0) {
                  setTab(1);
                }
              }}
              fluid
            />
          </Tabs>
          <Stack.Item grow>
            <Section fill scrollable>
              <Table>
                {material_filtered.map((material) => (
                  <MaterialRow
                    compact={compact}
                    key={material.id}
                    material={material}
                    onRelease={(amount) => {
                      if (material.category === 'material') {
                        act('Release', {
                          id: material.id,
                          sheets: amount,
                        });
                      } else {
                        act('Smelt', {
                          id: material.id,
                          sheets: amount,
                        });
                      }
                    }}
                  />
                ))}
              </Table>
            </>
          )) || (
            <Button
              icon="save"
              content="Insert design disk"
              onClick={() => act('diskInsert')}
            />
          )}
        </Section>
        <Section title="Materials">
          <Table>
            {materials.map((material) => (
              <MaterialRow
                key={material.id}
                material={material}
                onRelease={(amount) =>
                  act('Release', {
                    id: material.id,
                    sheets: amount,
                  })
                }
              />
            ))}
          </Table>
        </Section>
        <Section title="Alloys">
          <Table>
            {alloys.map((material) => (
              <MaterialRow
                key={material.id}
                material={material}
                onRelease={(amount) =>
                  act('Smelt', {
                    id: material.id,
                    sheets: amount,
                  })
                }
              />
            ))}
          </Table>
        </Section>
      </Window.Content>
    </Window>
  );
};

const MaterialRow = (props) => {
  const { data } = useBackend();
  const { compact } = props;
  const { material_icons } = data;
  const { material, onRelease } = props;

  const display = material_icons.find(
    (mat_icon) => mat_icon.id === material.id,
  );

  const amountAvailable = Math.floor(material.amount);
  return (
    <Table.Row className="candystripe" collapsing>
      {!compact && (
        <Table.Cell collapsing>
          <Image
            m={1}
            src={`data:image/jpeg;base64,${display.product_icon}`}
            height="18px"
            width="18px"
            style={{
              verticalAlign: 'middle',
            }}
          />
        </Table.Cell>
      )}
      <Table.Cell>{toTitleCase(material.name)}</Table.Cell>
      <Table.Cell collapsing textAlign="left">
        <Box color="label">
          {formatSiUnit(sheet_amounts, 0)}{' '}
          {material.amount === 1 ? 'sheet' : 'sheets'}
        </Box>
      </Table.Cell>
      <Table.Cell collapsing textAlign="right">
        <Box mr={2} color="label" inline>
          {amountAvailable} sheets
        </Box>
      </Table.Cell>
      <Table.Cell collapsing>
        <NumberInput
          width="32px"
          step={1}
          stepPixelSize={5}
          minValue={1}
          maxValue={50}
          value={amount}
          onChange={(e, value) => setAmount(value)}
        />
        <Button
          disabled={amountAvailable < 1}
          content="Release"
          onClick={() => onRelease(amount)}
        />
      </Table.Cell>
    </Table.Row>
  );
};
