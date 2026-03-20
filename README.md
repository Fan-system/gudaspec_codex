<div align="center">
**基于 RPI 与 OpenSpec 的纯 Codex 分阶段开发技能**

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT) [![Codex Skill](https://img.shields.io/badge/Codex-Skill-green.svg)](#)

---

## 一、项目简介

这个仓库现在提供的是一个 **Codex skill**，而不是 `Claude Code` 自定义命令。

仓库基于于[GuDaStudio/commands](https://github.com/GuDaStudio/commands)项目而来，核心技能名为 `gudaspec`，把原本依赖 `Claude Code + Codex/Gemini` 的流程，修改为 **Codex 原生可执行** 的 `Research -> Plan -> Implementation` 工作流。它仍然保留原项目的核心思想：

- 先把需求收敛成约束，而不是直接写代码
- 在 Plan 阶段消除关键决策点
- 在 Implementation 阶段由主agent统筹多个子agent产出补丁、审查重构并逐项验证
- 使用 OpenSpec 作为规格与执行之间的中间层

## 二、目录结构

```text
gudaspec/
├── SKILL.md
├── agents/openai.yaml
└── references/
    ├── init.md
    ├── research.md
    ├── plan.md
    └── implementation.md
```

## 三、安装

### 1. 获取仓库

```bash
git clone https://github.com/Fan-system/gudaspec_codex.git
cd gudaspec_codex
```

### 2. 安装 Skill

Linux / macOS:

```bash
# 用户级安装（所有项目生效）
./install.sh --user

# 项目级安装（仅当前项目生效）
./install.sh --project

# 自定义路径
./install.sh --target /your/custom/path
```

默认安装目标：

- 用户级：`~/.codex/skills/gudaspec`
- 项目级：`./.codex/skills/gudaspec`

为更好的使用codex中的协作，可以采用或参考项目中的`AGENTS.md`。

## 四、使用方式

安装完成后，可以在 Codex 中直接自然语言触发，或显式提到 `$gudaspec`。

示例：

```text
使用 $gudaspec 初始化当前项目的 openspec 工作区
```

```text
使用 $gudaspec research 流程分析这个需求，并输出约束集与 proposal
```

```text
使用 $gudaspec plan 流程，把当前 proposal 收敛成零决策执行计划
```

```text
使用 $gudaspec implementation 流程，默认采用多子agent并行产出 unified diff patch，由主agent落地代码，先交独立子agent审查，再进行测试与收尾验证
```

如果你不显式写 `$gudaspec`，只要请求本身明显是在做阶段化的 OpenSpec/RPI 工作流，Codex 也可以按技能描述自动匹配。

补充说明：文档里提到的 `rg` 指的是 `ripgrep`，一种常用的快速代码搜索工具。它是可选增强，不是硬性前置依赖；若本机未安装，可回退使用 `grep`、`find` 等命令。

## 五、四个阶段

### `init`

- 检查 `openspec` 是否可用
- 初始化当前仓库的 OpenSpec 环境
- 输出缺失依赖与后续动作

### `research`

- 扫描相关代码与文档
- 形成硬约束、软约束、依赖、风险、成功判据
- 生成或更新 OpenSpec proposal

### `plan`

- 找出 proposal 中仍未闭合的决策点
- 向用户补齐必要约束
- 形成可顺序执行的实现计划
- 补充适用的性质/不变量，并严格校验 spec

### `implementation`

- 默认采用多子agent，按代码边界或任务所有权拆分
- 子agent返回 `unified diff patch`、涉及文件、局部检查结论、假设与风险
- 主agent不得直接应用补丁，必须审查、去冗余、统一命名与结构后再落地
- 主agent完成每一项任务后，都要先经过独立审查
- 审查通过后，再执行该任务的测试、检查与收尾验证
- 保持实现与 spec 对齐
- 汇报残余风险与未验证项

## 六、设计变化

相对于原仓库，当前版本有这些关键调整：

- 不再依赖 `Claude Code` 斜杠命令
- 不再依赖 `Claude Code + 外部 Codex/Gemini MCP` 的工作流
- 默认由 Codex 自身完成研究、规划、实现与验证
- 在实现阶段，默认使用 Codex 子agent并行产出补丁，由主agent负责最终代码主权
- 保留 OpenSpec 作为规格载体

## FAQ

### Q1: 这还是原来的多模型协作方案吗？

不是。现在是 **纯 Codex 工作流**。默认不依赖外部模型，但在实现阶段默认使用 Codex 子agent 协作，由主agent统一审查与落地。

### Q2: 必须安装 OpenSpec 吗？

如果你希望完整保留 `proposal -> plan -> implementation` 的规格化流程，就需要安装 OpenSpec。`init` 阶段会检查并提示。

### Q3: 这个 skill 适合什么任务？

适合中大型编码任务、需求不够明确的改造任务、以及需要先出规格再实施的项目型工作。

---

## 许可证

本项目采用 [MIT License](LICENSE) 开源协议。

Copyright (c) 2025 [guda.studio](mailto:gudaclaude@gmail.com)

---

<div align="center">
