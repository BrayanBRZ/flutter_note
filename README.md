# Configuração do Ambiente Flutter

## Interface e aparência

A Agenda Escolar usa um tema central com quatro combinações: padrão e
monocromática, cada uma em claro ou escuro. As configurações de aparência
preservam as cores das tags e dos avisos. A primeira abertura usa padrão claro
e calendário de uma semana; as escolhas seguintes são salvas no dispositivo.

O calendário oferece uma semana, duas semanas ou um mês, com navegação por
setas, gesto horizontal e retorno a hoje. As atividades do período exibido
ficam agrupadas por dia em uma única rolagem. Selecionar uma data destaca o
grupo correspondente sem filtrar as outras atividades.

Comum e Urgente são tags padrão criadas na instalação e permitem editar
nome, cor e lembrete. A lista usa ícones de edição e exclusão na mesma linha
de cada tag. A exclusão transfere suas atividades para uma tag disponível;
ao menos uma tag precisa permanecer cadastrada. Alterações e exclusões não
são desfeitas ao reabrir o app.

Os formulários de atividades, tags e matérias usam seções com campos de
preenchimento suave, destaque de foco e seletores adaptáveis. Tags exibem
uma prévia de nome e cor. As telas principais mostram o ícone de livro no
cabeçalho; Tags e Estatísticas usam uma seta no lugar do livro para voltar às
Configurações. Formulários e detalhes mostram Voltar quando há uma tela
anterior. Todos os cabeçalhos usam a mesma altura mínima e crescem quando
necessário para acomodar texto ampliado.
Detalhes e edição de atividades mantêm a navegação inferior; o retorno usa
apenas a seta do cabeçalho, sem um botão grande adicional.

Os temas e tokens de vidro fosco ficam em `lib/shared/app_theme.dart`;
as preferências usam `SharedPreferencesAsync`. O banco de atividades e suas
regras de recorrência e lembretes permanecem os mesmos.

Para validar:

```sh
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

Os testes de widgets verificam os temas em larguras de 320, 390 e 430 px,
orientação horizontal, texto ampliado, teclado, seleção de datas e diálogos.
Eles geram capturas com dados de teste em `build/ui_previews/`.
A compilação e inspeção Android exigem Android SDK e emulador ou dispositivo;
a validação nativa de iOS exige macOS.

## 📌 Descrição

Esta atividade teve como objetivo configurar o ambiente de desenvolvimento Flutter e executar um projeto padrão em diferentes plataformas. Durante o processo foram realizados testes no emulador Android, na Web e em um dispositivo físico, além da análise da estrutura básica de um projeto Flutter.

Também foi realizada a gravação de um vídeo técnico demonstrando todas as etapas da atividade.

https://drive.google.com/file/d/1jRE65p4n_9Fnnv9KZwkQBpvlaaJhmrJf/view?usp=sharing

---

## 🛠️ Etapas Realizadas

1. Instalação e configuração do **Flutter SDK**.
2. Instalação do **Visual Studio Code** com as extensões **Flutter** e **Dart**.
3. Execução do comando `flutter doctor` para verificar a instalação.
4. Criação de um projeto Flutter padrão.
