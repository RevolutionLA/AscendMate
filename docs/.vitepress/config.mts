import { defineConfig } from 'vitepress'

// 站点页脚 / 主题色定义
const nav = [
  { text: '首页', link: '/' },
  { text: '快速开始', link: '/guide/' },
  { text: '环境搭建', link: '/setup/' },
  { text: '昇腾硬件', link: '/hardware/' },
  { text: '大模型训练', link: '/training/' },
  { text: '模型推理', link: '/inference/' },
  { text: '算子开发', link: '/ops/' },
  { text: '工具链', link: '/tools/' },
  { text: '资源导航', link: '/resources/' },
  { text: '问题定位 FAQ', link: '/faq/' },
  { text: '贡献', link: '/contributing/' },
]

const sidebarGuide = [
  {
    text: '快速开始',
    items: [
      { text: '快速开始总览', link: '/guide/' },
      { text: '认识 AscendMate', link: '/guide/what-is-ascendmate' },
      { text: '典型部署场景', link: '/guide/use-cases' },
      { text: '如何选择使用路径', link: '/guide/choose-your-path' },
      { text: '从零到上手：7 步走', link: '/guide/seven-steps' },
      { text: '硬件与软件全景', link: '/guide/ascend-landscape' },
    ],
  },
]

// 部署基础路径：GitHub Pages 子路径部署(如 /ascendmate/)时通过环境变量 VITE_BASE 注入
// 本地开发 / 自定义域名根路径时留空即可
const base = process.env.VITE_BASE || '/'

// GitHub 仓库地址
const repo = process.env.ASCENDMATE_GITHUB || 'https://github.com/RevolutionLA/AscendMate'
const editPrefix = `${repo.replace(/\/+$/, '')}/edit/master/docs/`

export default defineConfig({
  title: '昇腾之家',
  base,
  description: '一站式昇腾智算服务器使用手册 —— 环境搭建、模型微调、推理部署、算子开发的完整实战指南',
  lang: 'zh-CN',
  cleanUrls: true,
  lastUpdated: true,
  markdown: {
    lineNumbers: true,
  },
  head: [
    ['meta', { name: 'theme-color', content: '#f4f6f8' }],
    ['link', { rel: 'preconnect', href: 'https://fonts.googleapis.com' }],
    ['link', { rel: 'preconnect', href: 'https://fonts.gstatic.com', crossorigin: 'anonymous' }],
    ['link', { rel: 'stylesheet', href: 'https://fonts.googleapis.com/css2?family=IBM+Plex+Mono:wght@400;500;600&family=IBM+Plex+Sans:wght@400;500;600;700&display=swap' }],
    ['link', { rel: 'icon', type: 'image/png', href: `${base.replace(/\/+$/, '')}/ascend/ascend-favicon.png` }],
    ['meta', { name: 'keywords', content: '昇腾, Ascend, NPU, Atlas, CANN, torch_npu, MindSpeed, vLLM-Ascend, MindIE, LLaMA-Factory, AscendC, MindStudio, 智算服务器, 大模型, 训推, 华为' }],
  ],
  themeConfig: {
    logo: '/ascend/ascend-logo.svg',
    nav,
    outline: { label: '本页目录', level: [2, 3] },
    search: {
      provider: 'local',
      options: {
        translations: {
          button: { buttonText: '搜索文档', buttonAriaLabel: '搜索文档' },
          modal: {
            noResultsText: '没有找到相关内容',
            resetButtonTitle: '清空搜索条件',
            footer: {
              selectText: '选择',
              navigateText: '切换',
              closeText: '关闭',
            },
          },
        },
      },
    },
    docFooter: {
      prev: '上一篇',
      next: '下一篇',
    },
    editLink: {
      pattern: `${editPrefix}:path`,
      text: '在 GitHub 上编辑此页',
    },
    lastUpdated: {
      text: '最后更新',
    },
    socialLinks: [
      { icon: 'github', link: repo },
    ],
    sidebar: {
      '/guide/': sidebarGuide,
      '/setup/': [
        {
          text: '环境搭建',
          collapsed: false,
          items: [
            { text: '环境搭建总览', link: '/setup/' },
            { text: '01 服务器上电与规划', link: '/setup/server-onboarding' },
            { text: '02 操作系统选择与安装', link: '/setup/os-install' },
            { text: '03 固件与驱动安装', link: '/setup/firmware-driver' },
            { text: '04 CANN 安装', link: '/setup/cann-install' },
            { text: '05 PyTorch + torch_npu 安装', link: '/setup/torch-npu-install' },
            { text: '06 MindSpore 安装', link: '/setup/mindspore-install' },
            { text: '07 Docker 镜像与离线部署', link: '/setup/docker-offline' },
            { text: '08 环境自检清单', link: '/setup/checklist' },
          ],
        },
      ],
      '/hardware/': [
        {
          text: '昇腾硬件',
          collapsed: false,
          items: [
            { text: '硬件产品全景', link: '/hardware/' },
            { text: '集群形态', link: '/hardware/cluster' },
            { text: 'A2 服务器', link: '/hardware/a2-server' },
            { text: 'A3 服务器', link: '/hardware/a3-server' },
            { text: 'AI 推理卡', link: '/hardware/inference-card' },
            { text: '开发套件与模组', link: '/hardware/devkit-module' },
          ],
        },
      ],
      '/training/': [
        {
          text: '大模型训练',
          collapsed: false,
          items: [
            { text: '训练全景', link: '/training/' },
            { text: 'LLaMA-Factory 微调实操', link: '/training/llama-factory' },
            { text: 'MindSpeed 预训练', link: '/training/mindspeed' },
            { text: 'PyTorch 模型迁移', link: '/training/pytorch-migration' },
            { text: 'MindSpore 模型迁移', link: '/training/mindspore-migration' },
          ],
        },
      ],
      '/inference/': [
        {
          text: '模型推理',
          collapsed: false,
          items: [
            { text: '推理全景', link: '/inference/' },
            { text: 'MindIE 服务化拉起', link: '/inference/mindie' },
            { text: 'vLLM-Ascend 部署', link: '/inference/vllm-ascend' },
            { text: 'SGLang-Kernel-NPU', link: '/inference/sglang' },
            { text: 'Dify 平台部署', link: '/inference/dify' },
          ],
        },
      ],
      '/ops/': [
        {
          text: '算子开发',
          collapsed: false,
          items: [
            { text: '算子开发全景', link: '/ops/' },
            { text: 'Ascend C 算子开发', link: '/ops/ascend-c' },
            { text: 'Triton-Ascend', link: '/ops/triton-ascend' },
            { text: 'CATLASS 快速开始', link: '/ops/catlass' },
          ],
        },
      ],
      '/tools/': [
        {
          text: '工具链',
          collapsed: false,
          items: [
            { text: '工具链全景', link: '/tools/' },
            { text: 'MindStudio', link: '/tools/mindstudio' },
            { text: '精度调试', link: '/tools/precision-debug' },
            { text: '性能调优（Profiling）', link: '/tools/profiling' },
          ],
        },
      ],
      '/resources/': [
        {
          text: '资源导航',
          collapsed: false,
          items: [
            { text: '资源总览', link: '/resources/' },
            { text: '完整链接导航表', link: '/resources/links' },
            { text: '样例代码与模型', link: '/resources/samples-models' },
            { text: '镜像与软件下载', link: '/resources/download' },
            { text: '生态与社区', link: '/resources/community' },
          ],
        },
      ],
      '/faq/': [
        {
          text: '问题定位',
          collapsed: false,
          items: [
            { text: 'FAQ 总览', link: '/faq/' },
            { text: '环境搭建类问题', link: '/faq/setup-issues' },
            { text: '训练类问题', link: '/faq/training-issues' },
            { text: '推理类问题', link: '/faq/inference-issues' },
            { text: '性能与精度问题', link: '/faq/perf-precision-issues' },
          ],
        },
      ],
      '/contributing/': [
        {
          text: '参与贡献',
          collapsed: false,
          items: [
            { text: '如何贡献', link: '/contributing/' },
          ],
        },
      ],
    },
    footer: {
      message: 'AscendMate · 昇腾之家 © 昇腾技术团队',
      copyright: '内容基于公开资料整理，仅供学习与参考',
    },
  },
})
