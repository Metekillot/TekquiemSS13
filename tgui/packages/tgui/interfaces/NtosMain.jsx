import { useBackend } from '../backend';
import { Button, ColorBox, Section, Table } from '../components';
import { NtosWindow } from '../layouts';

export const NtosMain = (props) => {
  const { act, data } = useBackend();
  const {
    device_theme,
    programs = [],
    has_light,
    light_on,
    comp_light_color,
    removable_media = [],
    cardholder,
    login = [],
  } = data;
  const filtered_programs = programs.filter(
    (program) => program.header_program,
  );
  return (
    <NtosWindow
      title={
        (device_theme === 'syndicate' && 'Syndix Main Menu') || 'NtOS Main Menu'
      }
      theme={device_theme}
      width={400}
      height={500}
    >
      <NtosWindow.Content scrollable>
        {Boolean(
          removable_media.length ||
            programs.some((program) => program.header_program),
        ) && (
          <Section>
            <Stack>
              {!!has_light && (
                <Stack.Item grow>
                  <Button
                    width="144px"
                    icon="lightbulb"
                    selected={light_on}
                    onClick={() => act('PC_toggle_light')}>
                    Flashlight: {light_on ? 'ON' : 'OFF'}
                  </Button>
                  <Button ml={1} onClick={() => act('PC_light_color')}>
                    Color:
                    <ColorBox ml={1} color={comp_light_color} />
                  </Button>
                </Stack.Item>
              )}
              {removable_media.map((device) => (
                <Stack.Item key={device}>
                  <Button
                    fluid
                    icon="eject"
                    content={device}
                    onClick={() => act('PC_Eject_Disk', { name: device })}
                    disabled={!device}
                  />
                </Stack.Item>
              ))}
            </Stack>
          </Section>
        )}
        {!!cardholder && (
          <Section
            title="User Login"
            buttons={
              <>
                <Button
                  icon="eject"
                  content="Eject ID"
                  disabled={!proposed_login.IDName}
                  onClick={() => act('PC_Eject_Disk', { name: 'ID' })}
                />
                <Button
                  icon="dna"
                  content="Imprint ID"
                  disabled={
                    !proposed_login.IDName ||
                    (proposed_login.IDName === login.IDName &&
                      proposed_login.IDJob === login.IDJob)
                  }
                  onClick={() => act('PC_Imprint_ID', { name: 'ID' })}
                />
              )}
            </>
          }
        >
          <Table>
            <Table.Row>
              ID Name:{' '}
              {show_imprint
                ? login.IDName +
                  ' ' +
                  (proposed_login.IDName
                    ? '(' + proposed_login.IDName + ')'
                    : '')
                : proposed_login.IDName ?? ''}
            </Table.Row>
            <Table.Row>
              Assignment:{' '}
              {show_imprint
                ? login.IDJob +
                  ' ' +
                  (proposed_login.IDJob ? '(' + proposed_login.IDJob + ')' : '')
                : proposed_login.IDJob ?? ''}
            </Table.Row>
          </Table>
        </Section>
        {!!pai && (
          <Section title="pAI">
            <Table>
              <Table.Row>
                <Table.Cell>
                  <Button
                    fluid
                    icon="eject"
                    color="transparent"
                    content="Eject pAI"
                    onClick={() =>
                      act('PC_Pai_Interact', {
                        option: 'eject',
                      })
                    }
                  />
                </Table.Cell>
              </Table.Row>
              <Table.Row>
                <Table.Cell>
                  <Button
                    fluid
                    icon="cat"
                    color="transparent"
                    content="Configure pAI"
                    onClick={() =>
                      act('PC_Pai_Interact', {
                        option: 'interact',
                      })
                    }
                  />
                </Table.Cell>
              </Table.Row>
            </Table>
          </Section>
        )}
        <Section title="Programs">
          <Table>
            {programs.map((program) => (
              <Table.Row key={program.name}>
                <Table.Cell>
                  <Button
                    fluid
                    color={program.alert ? 'yellow' : 'transparent'}
                    icon={program.icon}
                    content={program.desc}
                    onClick={() =>
                      act('PC_runprogram', {
                        name: program.name,
                        is_disk: false,
                      })
                    }
                  />
                </Table.Cell>
                <Table.Cell collapsing width="18px">
                  {!!program.running && (
                    <Button
                      color="transparent"
                      icon="times"
                      tooltip="Close program"
                      tooltipPosition="left"
                      onClick={() =>
                        act('PC_killprogram', {
                          name: program.name,
                        })
                      }
                    />
                  )}
                </Table.Cell>
              </Table.Row>
            ))}
          </Table>
        </Section>
        {!!disk && (
          <Section
            // pain
            title={
              disk_name
                ? disk_name.substring(0, disk_name.length - 5)
                : 'No Job Disk Inserted'
            }
            buttons={
              <Button
                icon="eject"
                content="Eject Disk"
                disabled={!disk_name}
                onClick={() => act('PC_Eject_Disk', { name: 'remove_disk' })}
              />
            }>
            <Table>
              {disk_programs.map((program) => (
                <Table.Row key={program.name}>
                  <Table.Cell>
                    <Button
                      fluid
                      color={program.alert ? 'yellow' : 'transparent'}
                      icon={program.icon}
                      content={program.desc}
                      onClick={() =>
                        act('PC_runprogram', {
                          name: program.name,
                          is_disk: true,
                        })
                      }
                    />
                  </Table.Cell>
                  <Table.Cell collapsing width="18px">
                    {!!program.running && (
                      <Button
                        color="transparent"
                        icon="times"
                        tooltip="Close program"
                        tooltipPosition="left"
                        onClick={() =>
                          act('PC_killprogram', {
                            name: program.name,
                          })
                        }
                      />
                    )}
                  </Table.Cell>
                </Table.Row>
              ))}
            </Table>
          </Section>
        )}
      </NtosWindow.Content>
    </NtosWindow>
  );
};

const ProgramsTable = (props) => {
  const { act, data } = useBackend();
  const { programs = [] } = data;
  // add the program filename to this list to have it excluded from the main menu program list table
  const filtered_programs = programs.filter(
    (program) => !program.header_program,
  );

  return (
    <Section title="Programs">
      <Table>
        {filtered_programs.map((program) => (
          <Table.Row key={program.name}>
            <Table.Cell>
              <Button
                fluid
                color={program.alert ? 'yellow' : 'transparent'}
                icon={program.icon}
                content={program.desc}
                onClick={() =>
                  act('PC_runprogram', {
                    name: program.name,
                  })
                }
              />
            </Table.Cell>
            <Table.Cell collapsing width="18px">
              {!!program.running && (
                <Button
                  color="transparent"
                  icon="times"
                  tooltip="Close program"
                  tooltipPosition="left"
                  onClick={() =>
                    act('PC_killprogram', {
                      name: program.name,
                    })
                  }
                />
              )}
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </Section>
  );
};
