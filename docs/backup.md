# Backup manual da agenda

O app continua usando SQLite no dispositivo. Em **Configurações → Backup**, o
usuário entra numa conta com e-mail e senha para salvar ou recuperar sua agenda.

## Comportamento

- **Salvar backup na nuvem:** captura as quatro tabelas SQLite numa transação
  e substitui o documento `users/{uid}/backups/current` no Firestore. O documento
  contém um único retrato; itens removidos localmente desaparecem do backup.
- **Restaurar backup da nuvem:** consulta o servidor, valida o retrato e pede
  confirmação. Ao confirmar, apaga e repõe atividades, tags, matérias e
  lembretes numa única transação SQLite. IDs, relacionamentos, recorrências e
  contadores de IDs são preservados. Qualquer falha na transação desfaz toda a
  restauração e mantém a agenda anterior.
- As duas operações exibem um modal de aviso e permitem cancelar. Restaurar
  nunca mescla os dados. As telas anteriores são removidas depois da restauração
  para evitar detalhes de atividades que já não existem.
- Entrar/sair da conta não altera os dados locais. Cada conta mantém sua própria
  cópia na nuvem; salvar envia a agenda atual do dispositivo para a conta exibida.
- O retrato inclui as tabelas `task`, `subject`, `tag` e `reminder` e os contadores
  de `sqlite_sequence`. Preferências de aparência e calendário permanecem no
  dispositivo, em SharedPreferences.

## Conectar o projeto agenda-escolar-1bae1 (Android e web)

O arquivo `lib/firebase_options.dart` contém as opções reais dos apps registrados
no projeto **Agenda Escolar** (`agenda-escolar-1bae1`). Os apps são **Agenda Escolar
Android**, com pacote `com.example.meu_app`, e **Agenda Escolar Web**. A configuração
é cliente e não contém chaves de conta de serviço. O Firebase é inicializado ao
abrir a tela Backup; a agenda local continua disponível sem acesso à nuvem.

O projeto está configurado no plano gratuito **Spark**, sem faturamento vinculado.
O login por e-mail/senha está habilitado, o Firestore Standard `(default)` foi
criado em **São Paulo (`southamerica-east1`)**, as regras deste repositório foram
publicadas e o campo `backups.snapshot` está isento de indexação. Não foram
ativados os backups programados pagos do Firestore: o backup é feito pelo app.

Os passos abaixo permitem conferir ou refazer essa configuração:

1. No [Console Firebase](https://console.firebase.google.com/project/agenda-escolar-1bae1/overview),
   habilite **Authentication → Método de login → E-mail/senha**.
2. Crie o banco **Cloud Firestore**, edição Standard, se ainda não existir.
3. Instale as ferramentas oficiais, se necessário:

   ```powershell
   npm install -g firebase-tools
   dart pub global activate flutterfire_cli
   ```

4. Na raiz do projeto, entre na conta e gere as configurações:

   ```powershell
   firebase login
   flutterfire configure --project=agenda-escolar-1bae1 --platforms=android,web
   ```

   A configuração Android deve corresponder ao pacote `com.example.meu_app`.
   O comando gera `lib/firebase_options.dart` com as opções de cada plataforma.
   Os serviços Firebase são inicializados ao abrir a tela Backup.

5. Publique as regras de acesso e a isenção de índice do retrato:

   ```powershell
   firebase deploy --only firestore --project=agenda-escolar-1bae1
   ```

   Revise as regras existentes antes desse comando se o projeto Firebase atender
   outros apps. As regras incluídas autorizam somente o proprietário da conta a
   ler e substituir `users/{uid}/backups/current`.

6. Execute `flutter pub get` e reinicie o app. Para Android, é necessário ter o
   Android SDK configurado; para compilar Windows, o Flutter pode exigir o Modo
   de Desenvolvedor para criar os links dos plugins.

Referências oficiais: [configuração Flutter](https://firebase.google.com/docs/flutter/setup),
[Authentication](https://firebase.google.com/docs/auth/flutter/password-auth),
[REST do Firestore](https://firebase.google.com/docs/firestore/use-rest-api).

## Limite e conexão

Para manter esta primeira versão pequena, o retrato é JSON em um único documento.
O app limita seu conteúdo a **900 KiB**, abaixo do limite de 1 MiB por documento
do Firestore. Uma agenda maior exigiria outro formato de armazenamento.

As requisições ao Firestore usam HTTPS e o token da conta Firebase Authentication.
As regras Firestore continuam sendo aplicadas. O envio usa PATCH sem `updateMask`,
que substitui o documento inteiro; a leitura GET vem diretamente do servidor.
Não há cache de leitura nem fila de envio offline. A interface só informa sucesso
após resposta do servidor. Se um envio perder a resposta, a interface avisa que
não foi possível confirmá-lo e orienta a consultar o backup.

## Validação

```powershell
flutter analyze
flutter test
flutter build web
```

Há também um teste integrado opcional contra o Firebase real:

```powershell
flutter test test/live_firebase_backup_test.dart --dart-define=RUN_FIREBASE_LIVE_TEST=true
```

Esse teste cria duas contas descartáveis, salva/substitui um retrato de teste,
restaura um SQLite em memória e verifica que outra conta e um visitante não
podem ler o backup. Ao final, remove o documento e as contas criadas. Ele não
roda nos testes normais e nunca usa o banco de dados real do dispositivo.

Validação realizada em 05/10/2026: análise sem problemas, 12 testes locais
aprovados, teste integrado contra o Firebase aprovado e compilação web de
produção aprovada. A tela Backup foi conferida no navegador usando essa
compilação. A compilação e a execução em Android ainda dependem da instalação
do Android SDK neste computador.

Para testar no projeto real, use uma conta de teste e uma instalação com dados
descartáveis. Salve uma agenda, crie/exclua itens, salve novamente e confira que
o documento contém apenas o último retrato. Faça outras alterações locais,
cancele o modal de restauração e confirme que nada mudou; depois confirme a
restauração e confira que a agenda voltou ao retrato salvo. Repita usando a mesma
conta em Android e web. Confirme também que outra conta não lê esse documento.
