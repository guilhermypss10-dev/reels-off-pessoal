# Reels Off — guia gratuito usando Windows + iPhone 14

## O que este pacote faz
Este **protótipo** usa ReplayKit para solicitar transmissão de tela e Vision (OCR) para **tentar reconhecer** o texto "Reels" no topo do Instagram original e emitir uma notificação. **Não bloqueia nem fecha a aba Reels**. Não acessa senha do Instagram. Nenhuma imagem é enviada pelo nosso código para servidor.

## Pré-requisitos
- PC com Windows 10/11, cabo USB, iPhone 14, conta Apple gratuita.
- Conta GitHub gratuita (repositório **público**, pois os minutos de Actions nos runners padrão são gratuitos para repositórios públicos; não publique dados privados nesse repositório).
- AltStore Classic + AltServer para Windows, obtidos no site oficial: https://altstore.io/ e instruções em https://faq.altstore.io/altstore-classic/how-to-install-altstore-windows
- iTunes e iCloud (preferencialmente instaladores disponibilizados pela Apple, de acordo com instruções oficiais da AltStore).

## Compilar sem Mac
1. Crie um repositório público VAZIO em https://github.com/new, chamado, por exemplo, `reels-off-pessoal`.
2. Extraia o ZIP deste projeto no Windows. Faça upload **do conteúdo interno da pasta ReelsOff** na raiz do repositório; preserve `.github/workflows/build-ios.yml`, `project.yml`, `ReelsOff/` e `ReelsMonitorExtension/`. No GitHub Web, pastas ocultas podem precisar ser adicionadas pela interface de criação de arquivo usando o caminho `.github/workflows/build-ios.yml`.
3. Vá em **Actions** > **Compilar iOS (IPA experimental sem assinatura)** > **Run workflow**. Se o evento `push` disparou a compilação, basta abrir a execução correspondente.
4. Se a execução funcionar, baixe o artefato `ReelsOff-IPA-experimental`. Descompacte o artefato para obter `ReelsOff-unsigned.ipa`.
5. **Observação:** este fluxo ainda não foi executado em runner real. Podem surgir erros de projeto/assinatura que precisem ser corrigidos.

## Tentar instalar sem pagar
1. Instale AltServer + AltStore Classic no Windows/iPhone segundo o manual oficial.
2. Ligue o iPhone ao PC, confie no computador e habilite o Modo de Desenvolvedor no iPhone (Ajustes > Privacidade e Segurança > Modo de Desenvolvedor, se disponível).
3. Tente adicionar `ReelsOff-unsigned.ipa` em **My Apps > +** no AltStore Classic. O AltStore tentará assinar o pacote usando sua conta Apple.
4. Um app com extensão ReplayKit pode falhar ao assinar com conta gratuita; **não há garantia de instalação**, mesmo com IPA compilado. Caso isso aconteça, guarde a mensagem do erro.
5. Apps assinados gratuitamente costumam precisar de renovação em até 7 dias, mantendo AltServer acessível.
6. Se instalar: abra Reels Off, permita notificações, toque no controle da transmissão e selecione a extensão. Depois teste o Instagram original.

## Privacidade
O projeto não contém chave, token ou função de upload. Mesmo assim, ao iniciar a captura do sistema, o iOS pode disponibilizar conteúdo de outras telas à extensão. Evite manter captura ativa quando abrir informações sensíveis; interrompa pelo indicador do iOS.

## Limitações importantes
- iOS não oferece uma API pública para ocultar a aba Reels de um aplicativo de terceiros.
- A extensão **não tem permissão para fechar o Instagram, simular toques ou desenhar um bloqueio por cima dele**.
- A notificação pode não aparecer imediatamente ou durante uso do Instagram.
- A detecção por texto depende da versão/idioma/layout da interface.
- Não executado aqui no Xcode/iPhone. Não marque o aplicativo como pronto para uso.
