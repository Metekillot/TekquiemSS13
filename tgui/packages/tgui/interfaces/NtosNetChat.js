import { useBackend } from '../backend';
import { Box, Button, Icon, Input, Section, Table } from '../components';
import { NtosWindow } from '../layouts';

export const NtosNetChat = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    can_admin,
    adminmode,
    authed,
    username,
    active_channel,
    is_operator,
    all_channels = [],
    clients = [],
    messages = [],
  } = data;
  const in_channel = (active_channel !== null);
  const authorized = (authed || adminmode);
  return (
    <NtosWindow
      width={1000}
      height={675}>
      <NtosWindow.Content>
        <Section height="600px">
          <Table height="580px">
            <Table.Row>
              <Table.Cell
                verticalAlign="top"
                style={{
                  width: '200px',
                }}>
                <Box
                  height="537px"
                  overflowY="scroll">
                  <Button.Input
                    fluid
                    content="New Channel..."
                    onCommit={(e, value) => act('PRG_newchannel', {
                      new_channel_name: value,
                    })} />
                  {all_channels.map(channel => (
                    <Button
                      fluid
                      key={channel.chan}
                      content={channel.chan}
                      selected={channel.id === active_channel}
                      color="transparent"
                      onClick={() => act('PRG_joinchannel', {
                        id: channel.id,
                      })} />
                  ))}
                </Box>
                <Button.Input
                  fluid
                  mt={1}
                  content={username + '...'}
                  currentValue={username}
                  onCommit={(e, value) => act('PRG_changename', {
                    new_name: value,
                  })} />
                {!!can_admin && (
                  <Button
                    fluid
                    mt={1}
                    content={username + '...'}
                    currentValue={username}
                    onCommit={(e, value) => act('PRG_changename', {
                      new_name: value,
                    })} />
                  {!!can_admin && (
                    <Button
                      fluid
                      bold
                      content={"ADMIN MODE: " + (adminmode ? 'ON' : 'OFF')}
                      color={adminmode ? 'bad' : 'good'}
                      onClick={() => act('PRG_toggleadmin')} />
                  )}
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
          <Stack.Divider />
          <Stack.Item grow={4}>
            <Stack vertical fill>
              <Stack.Item grow>
                <Section scrollable fill>
                  {in_channel && (
                    authorized ? (
                      messages.map(message => (
                        <Box
                          key={message.msg}>
                          {message.msg}
                        </Box>
                      ))
                    ) : (
                      <Box
                        textAlign="center">
                        <Icon
                          name="exclamation-triangle"
                          mt={4}
                          fontSize="40px" />
                        <Box
                          mt={1}
                          bold
                          fontSize="18px">
                          THIS CHANNEL IS PASSWORD PROTECTED
                        </Box>
                        <Box mt={1}>
                          INPUT PASSWORD TO ACCESS
                        </Box>
                      </Box>
                    )
                  )}
                </Box>
                <Input
                  fluid
                  selfClear
                  mt={1}
                  onEnter={(e, value) => act('PRG_speak', {
                    message: value,
                  })} />
              )}
            </Stack>
          </Stack.Item>
          {!!in_channel && (
            <>
              <Stack.Divider />
              <Stack.Item grow={2}>
                <Stack vertical fill>
                  <Stack.Item grow>
                    <Section scrollable fill>
                      <Stack vertical>
                        {displayed_clients.map(client => (
                          <Stack height="18px" fill key={client.name}>
                            <Stack.Item
                              basis={0}
                              grow
                              color={client_color(client)}>
                              {client.name}
                            </Stack.Item>
                            {client !== this_client && (
                              <>
                                <Stack.Item>
                                  <Button
                                    disabled={this_client?.muted}
                                    compact
                                    icon="bullhorn"
                                    tooltip={!this_client?.muted
                                      && "Ping" || "You are muted!"}
                                    tooltipPosition="left"
                                    onClick={() => act('PRG_ping_user', {
                                      ref: client.ref,
                                    })} />
                                </Stack.Item>
                                {!!is_operator && (
                                  <Stack.Item>
                                    <Button
                                      compact
                                      icon={!client.muted
                                        && "volume-up" || "volume-mute"}
                                      color={!client.muted
                                        && "green" || "red"}
                                      tooltip={!client.muted
                                        && "Mute this User" || "Unmute this User"}
                                      tooltipPosition="left"
                                      onClick={() => act('PRG_mute_user', {
                                        ref: client.ref,
                                      })} />
                                  </Stack.Item>
                                )}
                              </>
                            )}
                          </Stack>
                        ))}
                      </Stack>
                    </Section>
                  </Stack.Item>
                  <Section>
                    <Stack.Item mb="8px">
                      Settings for {title}:
                    </Stack.Item>
                    <Stack.Item>
                      {!!(in_channel && authorized) && (
                        <>
                          <Button.Input
                            fluid
                            content="Save log..."
                            defaultValue="new_log"
                            onCommit={(e, value) => act('PRG_savelog', {
                              log_name: value,
                            })} />
                          <Button.Confirm
                            fluid
                            content="Leave Channel"
                            onClick={() => act('PRG_leavechannel')} />
                        </>
                      )}
                      {!!(is_operator && authed) && (
                        <>
                          <Button.Confirm
                            fluid
                            disabled={strong}
                            content="Delete Channel"
                            onClick={() => act('PRG_deletechannel')} />
                          <Button.Input
                            fluid
                            disabled={strong}
                            content="Rename Channel..."
                            onCommit={(e, value) => act('PRG_renamechannel', {
                              new_name: value,
                            })} />
                          <Button.Input
                            fluid
                            content="Set Password..."
                            onCommit={(e, value) => act('PRG_setpassword', {
                              new_password: value,
                            })} />
                        </>
                      )}
                    </Stack.Item>
                  </Section>
                </Stack>
              </Stack.Item>
            </>
          )}
        </Stack>
      </NtosWindow.Content>
    </NtosWindow>
  );
};
