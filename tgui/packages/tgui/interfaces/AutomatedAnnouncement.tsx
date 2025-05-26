import { Button, Input, LabeledList, Section } from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

const TOOLTIP_TEXT = `
  %PERSON will be replaced with their name.
  %RANK with their job.
`;

type Data = {
  arrivalToggle: BooleanLike;
  arrival: string;
  newheadToggle: BooleanLike;
  newhead: string;
};

export const AutomatedAnnouncement = (props) => {
  const { act, data } = useBackend<Data>();
  const { arrivalToggle, arrival, newheadToggle, newhead } = data;
  return (
    <Window title="Automated Announcement System" width={500} height={225}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <LabeledList>
              <LabeledList.Item label="Search">
                <Input fluid placeholder="Name/Line/Var" onChange={setSearch} />
              </LabeledList.Item>
            </LabeledList>
          </Stack.Item>
          <Stack.Item grow>
            {!sorted.length ? (
              <NoticeBox>{errorMessage}</NoticeBox>
            ) : (
              <Section fill scrollable>
                {sorted.map((entry, index) => (
                  <Section
                    key={entry.entryRef}
                    title={entry.name}
                    buttons={
                      <>
                        <Button
                          icon="info"
                          tooltip={
                            (entry.generalTooltip
                              ? entry.generalTooltip + '\n'
                              : '') +
                            Object.entries(entry.varsAndTooltipsMap)
                              .map(
                                ([varName, tooltip]) =>
                                  '%' + varName + ' ' + tooltip,
                              )
                              .join('\n')
                          }
                          tooltipPosition="left"
                        />
                        <Button
                          icon={entry.enabled ? 'power-off' : 'times'}
                          selected={entry.enabled}
                          disabled={!entry.modifiable}
                          tooltip={
                            !entry.modifiable
                              ? 'Editing disabled by CentCom!'
                              : undefined
                          }
                          onClick={() =>
                            act('Toggle', { entryRef: entry.entryRef })
                          }
                        >
                          {entry.enabled ? 'On' : 'Off'}
                        </Button>
                      </>
                    }
                  >
                    <Table>
                      {Object.entries(entry.announcementLinesMap).map(
                        ([lineKey, announcementLine]) => (
                          <Table.Row key={lineKey}>
                            <Table.Cell collapsing color="label">
                              {lineKey}:
                            </Table.Cell>
                            <Table.Cell>
                              <Input
                                fluid
                                value={announcementLine}
                                disabled={!entry.modifiable}
                                onBlur={(value) =>
                                  act('Text', {
                                    entryRef: entry.entryRef,
                                    lineKey,
                                    newText: value,
                                  })
                                }
                              />
                            </Table.Cell>
                          </Table.Row>
                        ),
                      )}
                    </Table>
                  </Section>
                ))}
              </Section>
            )}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
