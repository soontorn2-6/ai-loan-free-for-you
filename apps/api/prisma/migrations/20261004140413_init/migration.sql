BEGIN;

-- CreateEnum
CREATE TYPE "UserRole" AS ENUM ('BORROWER', 'OFFICER', 'ADMIN');

-- CreateEnum
CREATE TYPE "ApplicationStatus" AS ENUM ('DRAFT', 'SUBMITTED', 'UNDER_REVIEW', 'NEEDS_INFORMATION', 'APPROVED', 'REJECTED', 'CANCELLED');

-- CreateTable
CREATE TABLE "User" (
    "id" UUID NOT NULL,
    "demoAlias" TEXT NOT NULL,
    "role" "UserRole" NOT NULL,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "User_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "BorrowerProfile" (
    "id" UUID NOT NULL,
    "userId" UUID NOT NULL,
    "displayName" TEXT NOT NULL,

    CONSTRAINT "BorrowerProfile_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Application" (
    "id" UUID NOT NULL,
    "borrowerId" UUID NOT NULL,
    "reviewerId" UUID,
    "status" "ApplicationStatus" NOT NULL DEFAULT 'DRAFT',
    "revision" INTEGER NOT NULL DEFAULT 0,
    "requestedAmount" DECIMAL(18,2) NOT NULL,
    "currency" CHAR(3) NOT NULL DEFAULT 'THB',
    "termMonths" INTEGER NOT NULL,
    "productVersionId" TEXT NOT NULL,
    "submittedSnapshot" JSONB,
    "requestedInformation" JSONB,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ(3) NOT NULL,

    CONSTRAINT "Application_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Document" (
    "id" UUID NOT NULL,
    "applicationId" UUID NOT NULL,
    "storageKey" TEXT NOT NULL,
    "documentType" TEXT NOT NULL,
    "mimeType" TEXT NOT NULL,
    "sizeBytes" INTEGER NOT NULL,
    "reviewStatus" TEXT NOT NULL DEFAULT 'UPLOADED',
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Document_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ConsentRecord" (
    "id" UUID NOT NULL,
    "userId" UUID NOT NULL,
    "type" TEXT NOT NULL,
    "version" TEXT NOT NULL,
    "acceptedAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "evidenceReference" TEXT NOT NULL,

    CONSTRAINT "ConsentRecord_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ReviewDecision" (
    "id" UUID NOT NULL,
    "applicationId" UUID NOT NULL,
    "reviewerId" UUID NOT NULL,
    "action" TEXT NOT NULL,
    "reason" TEXT NOT NULL,
    "resultingRevision" INTEGER NOT NULL,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "ReviewDecision_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "AuditEvent" (
    "id" UUID NOT NULL,
    "actorId" UUID,
    "action" TEXT NOT NULL,
    "resourceType" TEXT NOT NULL,
    "resourceId" TEXT NOT NULL,
    "correlationId" TEXT NOT NULL,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "AuditEvent_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "User_demoAlias_key" ON "User"("demoAlias");

-- CreateIndex
CREATE UNIQUE INDEX "BorrowerProfile_userId_key" ON "BorrowerProfile"("userId");

-- CreateIndex
CREATE INDEX "Application_borrowerId_createdAt_id_idx" ON "Application"("borrowerId", "createdAt", "id");

-- CreateIndex
CREATE INDEX "Application_reviewerId_status_createdAt_id_idx" ON "Application"("reviewerId", "status", "createdAt", "id");

-- CreateIndex
CREATE UNIQUE INDEX "Document_storageKey_key" ON "Document"("storageKey");

-- CreateIndex
CREATE INDEX "Document_applicationId_idx" ON "Document"("applicationId");

-- CreateIndex
CREATE UNIQUE INDEX "ConsentRecord_userId_type_version_key" ON "ConsentRecord"("userId", "type", "version");

-- CreateIndex
CREATE INDEX "ReviewDecision_reviewerId_idx" ON "ReviewDecision"("reviewerId");

-- CreateIndex
CREATE UNIQUE INDEX "ReviewDecision_applicationId_resultingRevision_key" ON "ReviewDecision"("applicationId", "resultingRevision");

-- CreateIndex
CREATE INDEX "AuditEvent_resourceType_resourceId_createdAt_id_idx" ON "AuditEvent"("resourceType", "resourceId", "createdAt", "id");

-- CreateIndex
CREATE INDEX "AuditEvent_actorId_idx" ON "AuditEvent"("actorId");

-- AddForeignKey
ALTER TABLE "BorrowerProfile" ADD CONSTRAINT "BorrowerProfile_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Application" ADD CONSTRAINT "Application_borrowerId_fkey" FOREIGN KEY ("borrowerId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Application" ADD CONSTRAINT "Application_reviewerId_fkey" FOREIGN KEY ("reviewerId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Document" ADD CONSTRAINT "Document_applicationId_fkey" FOREIGN KEY ("applicationId") REFERENCES "Application"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ConsentRecord" ADD CONSTRAINT "ConsentRecord_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ReviewDecision" ADD CONSTRAINT "ReviewDecision_applicationId_fkey" FOREIGN KEY ("applicationId") REFERENCES "Application"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ReviewDecision" ADD CONSTRAINT "ReviewDecision_reviewerId_fkey" FOREIGN KEY ("reviewerId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "AuditEvent" ADD CONSTRAINT "AuditEvent_actorId_fkey" FOREIGN KEY ("actorId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- Structural demo data checks; product limits remain T13 decisions.
ALTER TABLE "Application"
  ADD CONSTRAINT "Application_amount_positive" CHECK ("requestedAmount" > 0),
  ADD CONSTRAINT "Application_term_positive" CHECK ("termMonths" > 0),
  ADD CONSTRAINT "Application_revision_nonnegative" CHECK ("revision" >= 0),
  ADD CONSTRAINT "Application_currency_format" CHECK ("currency" ~ '^[A-Z]{3}$');
ALTER TABLE "Document" ADD CONSTRAINT "Document_size_positive" CHECK ("sizeBytes" > 0);
ALTER TABLE "ReviewDecision" ADD CONSTRAINT "ReviewDecision_revision_positive" CHECK ("resultingRevision" > 0);

COMMIT;
