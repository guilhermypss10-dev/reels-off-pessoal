# Reels Off — versão 0.1 (experimental)

Protótipo SwiftUI para iPhone 14: ReplayKit Broadcast Upload Extension + Vision OCR local. **Não é um bloqueador funcional de Reels ainda**. Detecta heurísticamente o título "Reels" na parte superior da tela e tenta enviar uma notificação. Não solicita senha do Instagram, não envia a captura à internet e não modifica o Instagram.

## Requisitos
- Mac com Xcode e iPhone 14 (iOS 16 ou superior).
- XcodeGen no Mac (`brew install xcodegen`) ou criação manual dos dois targets no Xcode.
- Conta Apple para assinatura. Projetos com extensão podem exigir ajustes de assinatura/capacidades.

## Abrir e executar
1. Extraia o ZIP no Mac e execute `xcodegen generate` na pasta `ReelsOff`.
2. Abra `ReelsOff.xcodeproj` e selecione a equipe em Signing & Capabilities para **ambos** os targets (app e extensão).
3. Se os identificadores `com.pessoal.reelsoff` já estiverem ocupados, altere-os nos dois targets, e atualize `preferredExtension` em `ContentView.swift` para corresponder ao bundle ID da extensão.
4. Instale no iPhone pelo Xcode; autorize notificações.
5. Toque no botão de transmissão do sistema, selecione a extensão e autorize o compartilhamento da tela.
6. Abra o Instagram original; entre em Reels e compare com Direct e Stories.
7. Para parar: use o indicador de gravação/compartilhamento do iOS ou a Central de Controle.

## Limites conhecidos
- A heurística por OCR é intencionalmente simples e **não identifica com precisão garantida** a tela de Reels; depende do idioma e layout do Instagram.
- Notificações podem não aparecer enquanto o iOS apresenta conteúdo em primeiro plano. O protótipo não altera a interface do Instagram nem bloqueia a navegação.
- A captura de tela requer confirmação do usuário, pode consumir bateria e processa conteúdo sensível (por exemplo, mensagens) quando ativo, embora tudo permaneça local.
- A próxima fase exige teste real de reconhecimento, mecanismos de intervenção autorizados pelo sistema e validação das restrições de assinatura/entitlements.
- Projeto gerado no ambiente de desenvolvimento, **não compilado nem testado num iPhone ou Xcode**.


## Sem Mac, sem pagar (Windows)
Veja `GUIA_WINDOWS_GRATUITO.md` e o fluxo `.github/workflows/build-ios.yml` para tentar compilar no GitHub Actions e instalar com AltStore Classic. **Fluxo não testado; instalação de extensão pode falhar com conta gratuita.**


## Atualização automática (10/11/2026)
- O workflow na raiz do repositório em `.github/workflows/build.yml` passou a compilar automaticamente quando houver alteração em `ReelsOff/**` ou no próprio workflow na branch `main`.
- A primeira execução manual do usuário foi bem-sucedida (58 s; 1 artefato), conforme captura do GitHub Actions.
- O arquivo gerado é `ReelsOff-unsigned.ipa`: não possui assinatura Apple e **não é instalável diretamente** no iPhone.
- A compilação automática não instala nem assina o app. O usuário precisará autorizar a instalação no próprio aparelho por uma ferramenta compatível e pode enfrentar restrições de extensões com Apple ID gratuito.
- **O programa atual é um detector experimental com alertas, não um bloqueador funcional de Reels.** Não anunciar como app que bloqueia Reels.


## Iteração de diagnóstico (10/11/2026)
- Interface atualizada para consultar autorização de notificações e enviar uma notificação local de teste após 3 segundos.
- Detector melhorado anteriormente para exigir dois reconhecimentos OCR consecutivos e reduzir repetição de alertas; reconhecimento real no Instagram ainda não foi validado em dispositivo.
- **Limitação técnica:** ReplayKit/ScreenCaptureKit capturam conteúdo com permissão, mas não disponibilizam APIs públicas para ocultar ou bloquear uma área do Instagram original. Não confundir compilação bem-sucedida com bloqueio funcional.
- Para bloquear Reels preservando demais funcionalidades, pode ser necessário abrir mão do app original e usar uma experiência web filtrada. Essa alternativa não está implementada neste repositório.
- Sem acesso físico ao iPhone e assinatura/autorização de instalação, não é possível declarar o produto como 100% pronto.
