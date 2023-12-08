import { toTitleCase } from 'common/string';
import { useBackend, useLocalState } from '../backend';
import { BlockQuote, Box, Button, NumberInput, Section, Table } from '../components';
import { Window } from '../layouts';

export const OreRedemptionMachine = (props) => {
  const { act, data } = useBackend();
  const { disconnected, unclaimedPoints, materials, user } = data;
  const [tab, setTab] = useSharedState('tab', 1);
  const [searchItem, setSearchItem] = useLocalState('searchItem', '');
  const [compact, setCompact] = useSharedState('compact', false);
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
              <Table>
                {diskDesigns.map((design) => (
                  <Table.Row key={design.index}>
                    <Table.Cell>
                      File {design.index}: {design.name}
                    </Table.Cell>
                    <Table.Cell collapsing>
                      <Button
                        disabled={!design.canupload}
                        content="Upload"
                        onClick={() =>
                          act('diskUpload', {
                            design: design.index,
                          })
                        }
                      />
                    </Table.Cell>
                  </Table.Row>
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
  const { material_icons } = data;
  const { material, onRelease } = props;
  const [compact, setCompact] = useLocalState('compact', false);

  const [amount, setAmount] = useLocalState(
    context,
    'amount' + material.name,
    1
  );

  const amountAvailable = Math.floor(material.amount);
  return (
    <Table.Row className="candystripe" collapsing>
      {!compact && (
        <Table.Cell collapsing>
          <Box
            as="img"
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
