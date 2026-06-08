import { describe, it, expect } from '@ohos/hypium';
import {
  PreviewServerConfigRepository,
  ServerConfigSaveResult,
  ServerConfigValidationStatus
} from '../../../main/ets/features/settings/data/ServerConfigRepository';
import { ServerConfig, ServerEnvironment } from '../../../main/ets/core/sdk/ServerConfigBridge';

export default function serverConfigRepositoryTest(): void {
  describe('PreviewServerConfigRepository', () => {
    it('exposes bitwarden cloud as the default server config', 0, () => {
      let repository: PreviewServerConfigRepository = new PreviewServerConfigRepository();

      let config: ServerConfig = repository.getCurrentConfig();

      expect(config.environment).assertEqual(ServerEnvironment.BitwardenCom);
      expect(config.baseUrl).assertEqual('https://vault.bitwarden.com');
      expect(config.identityUrl).assertEqual('https://identity.bitwarden.com');
      expect(config.apiUrl).assertEqual('https://api.bitwarden.com');
      expect(config.iconsUrl).assertEqual('https://icons.bitwarden.net');
    });

    it('creates self-hosted endpoints from a base url', 0, () => {
      let repository: PreviewServerConfigRepository = new PreviewServerConfigRepository();

      let result: ServerConfigSaveResult = repository.saveSelfHostedBaseUrl('https://vault.example.com');

      expect(result.status).assertEqual(ServerConfigValidationStatus.Valid);
      expect(result.config.environment).assertEqual(ServerEnvironment.SelfHosted);
      expect(result.config.baseUrl).assertEqual('https://vault.example.com');
      expect(result.config.identityUrl).assertEqual('https://vault.example.com/identity');
      expect(result.config.apiUrl).assertEqual('https://vault.example.com/api');
      expect(result.config.iconsUrl).assertEqual('https://vault.example.com/icons');
    });

    it('rejects blank or insecure self-hosted urls', 0, () => {
      let repository: PreviewServerConfigRepository = new PreviewServerConfigRepository();

      let blank: ServerConfigSaveResult = repository.saveSelfHostedBaseUrl('');
      let insecure: ServerConfigSaveResult = repository.saveSelfHostedBaseUrl('http://vault.example.com');

      expect(blank.status).assertEqual(ServerConfigValidationStatus.MissingBaseUrl);
      expect(blank.message).assertEqual('请输入自托管服务器地址');
      expect(insecure.status).assertEqual(ServerConfigValidationStatus.RequiresHttps);
      expect(insecure.message).assertEqual('自托管服务器地址必须使用 HTTPS');
    });
  });
}
