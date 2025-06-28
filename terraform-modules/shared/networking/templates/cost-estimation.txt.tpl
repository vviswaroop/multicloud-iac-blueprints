Network Cost Estimation
========================

Cloud Provider: ${cloud_provider}
Region: ${region}

Estimated Monthly Costs (USD):

VPC and Basic Networking:
- VPC: $0 (no charge for VPC itself)

%{ if enable_nat_gateway ~}
NAT Gateway:
- Number of NAT Gateways: ${nat_gateway_count}
- Estimated cost per NAT Gateway: $45-50/month
- Total NAT Gateway cost: $${nat_gateway_count * 45}-$${nat_gateway_count * 50}/month
- Data processing charges: $0.045 per GB processed
%{ endif ~}

%{ if enable_transit_gateway ~}
Transit Gateway:
- Transit Gateway: $36/month
- Transit Gateway Attachment: $36/month per attachment
- Data processing: $0.02 per GB
%{ endif ~}

%{ if enable_vpn_gateway ~}
VPN Gateway:
- VPN Connection: $36/month
- Data transfer: Variable based on usage
%{ endif ~}

%{ if vpc_peering_count > 0 ~}
VPC Peering:
- Number of peering connections: ${vpc_peering_count}
- VPC Peering: $0 (no charge for peering connection itself)
- Data transfer charges: $0.01-0.02 per GB (varies by region)
%{ endif ~}

Data Transfer:
- Inbound data: $0 (generally free)
- Outbound data to internet: $0.09 per GB (first 1GB free per month)
- Inter-AZ data transfer: $0.01 per GB
- Cross-region data transfer: $0.02 per GB

Additional Considerations:
- Elastic IP addresses: $3.65/month if not attached to running instance
- Network Load Balancer: $16.20/month + $0.006 per LCU-hour
- Application Load Balancer: $16.20/month + $0.008 per LCU-hour

Notes:
- Prices are estimates and may vary by region
- Actual costs depend on data transfer volumes
- Consider AWS Free Tier eligibility for new accounts
- Monitor usage with AWS Cost Explorer

For accurate pricing, use the AWS Pricing Calculator:
https://calculator.aws.amazon.com/

Generated on: ${timestamp()}