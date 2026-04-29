# Sonar Exporter

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Next.js](https://img.shields.io/badge/Next.js-14+-black)](https://nextjs.org/)
[![TypeScript](https://img.shields.io/badge/TypeScript-5.0+-3178C6)](https://www.typescriptlang.org/)

> A powerful, secure, and user-friendly solution for exporting SonarQube issue reports with ease.

Para a versão em português deste README, clique [aqui](README.md).

## 🎯 Overview

Sonar Exporter is a Next.js application designed to bridge a critical gap in SonarQube's functionality: the ability to export issue reports in a simple, secure, and customizable manner. By leveraging SonarQube's official APIs, this tool empowers development teams to generate detailed reports without complex manual processes or security concerns.

## 🚀 Key Features

- **Seamless Export**: Generate comprehensive issue reports from SonarQube in multiple formats
- **Intuitive Interface**: Clean, responsive UI designed for developer productivity
- **Direct API Integration**: Real-time communication with SonarQube APIs
- **Privacy-First Architecture**: Zero data storage - all processing happens client-side
- **Multi-Project Support**: Handle multiple SonarQube projects effortlessly
- **Enterprise-Ready**: Built with security and scalability in mind

## 💡 Why Sonar Exporter?

While SonarQube excels at code quality analysis, it lacks robust export capabilities for issue reports. Development teams often struggle with:

- Manual report generation processes
- Limited export format options
- Security concerns with third-party tools
- Difficulty in customizing report outputs

Sonar Exporter addresses these pain points by providing a streamlined, secure solution that integrates directly with your existing SonarQube infrastructure.

## 🔒 Security & Privacy

Security is paramount in our design philosophy:

- **Zero Data Persistence**: No user credentials, tokens, or report data is stored
- **Client-Side Processing**: All operations occur in the user's browser
- **Direct API Communication**: No intermediary servers handling sensitive data
- **Transparent Architecture**: Open-source codebase for full auditability

## ⚡ Quick Start

### Prerequisites

- Node.js 18+ 
- npm or yarn
- Access to a SonarQube instance

### Installation

```bash
# Clone the repository
git clone https://github.com/your-org/sonar-exporter.git

# Navigate to project directory
cd sonar-exporter

# Install dependencies
npm install

# Start development server
npm run dev
```

### Usage

1. Open your browser and navigate to `http://localhost:3000`
2. Configure your SonarQube connection details
3. Select the project and filters for your report
4. Export your customized issue report

## 🛠 Technical Architecture

### Built With

- **Framework**: Next.js 14+ with App Router
- **Language**: TypeScript for type safety
- **Styling**: Tailwind CSS for rapid UI development
- **API Client**: Native fetch with proper error handling
- **Security**: Client-side token management

### Project Structure

```
sonar-exporter/
├── src/
│   ├── app/                 # Next.js App Router
│   │   ├── api/             # Next.js API routes
│   │   │   ├── sonar-issues/     # SonarQube issues endpoints
│   │   │   └── sonar-projects/   # SonarQube projects endpoints
│   │   └── components/      # Page-specific components
│   ├── assets/              # Static assets and resources
│   ├── context/             # React contexts for global state
│   ├── services/            # API services and external integrations
│   ├── styles/              # Global style files
│   └── types/               # TypeScript type definitions
├── public/                  # Public assets
└── docs/                    # Documentation

## 📊 Current Limitations

Current limitations are primarily bound by SonarQube's API constraints:

- **Pagination Limits**: Governed by SonarQube's API pagination rules
- **Filter Availability**: Limited to filters exposed by SonarQube APIs
- **Performance Boundaries**: Subject to SonarQube instance performance characteristics
- **Rate Limiting**: Adherence to SonarQube API rate limits

## 🗺 Roadmap

### Phase 1: Core Functionality ✅
- Basic issue export functionality
- Portuguese language support
- Responsive UI implementation
- Multiple export formats (PDF, Excel, CSV)

### Phase 2: Enhancement (In Progress)
- [ ] Complete English translation
- [ ] Advanced filtering options

## 📝 License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

## 🔧 Support

If you encounter any issues or have questions:

1. Check our [Documentation](docs/)
2. Search existing [Issues](https://github.com/fonteeboa/next-sonar-exporter/issues)
3. Create a new issue with detailed information

## 🌟 Acknowledgments

- SonarQube team for providing comprehensive APIs
- Next.js community for excellent documentation and support

---

**Built with ❤️ by the development team**

*Making SonarQube reporting accessible to everyone*