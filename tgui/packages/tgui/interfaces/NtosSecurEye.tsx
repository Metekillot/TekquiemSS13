import { NtosWindow } from '../layouts';
import { CameraContent } from './CameraConsole';

export const NtosSecurEye = (props, context) => {
  const { data } = useBackend<Data>(context);
  const { PC_device_theme } = data;

  return (
    <NtosWindow width={800} height={600} theme={PC_device_theme}>
      <NtosWindow.Content>
        <CameraContent />
      </NtosWindow.Content>
    </NtosWindow>
  );
};
